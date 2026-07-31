// This is the combined web server for Summer/Genelet admin and Aofei DSP paths.
package main

import (
	"context"
	"errors"
	"expvar"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/guruperl/aofei/dsp"
	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer/registry"
	"go.uber.org/zap"
)

func usage() {
	fmt.Fprintf(os.Stderr, "usage: unify --g=web_config --s=ssp_config\n")
	flag.PrintDefaults()
	os.Exit(2)
}

var gConf, sConf string
var isLocal bool

const shutdownTimeout = 15 * time.Second

func init() {
	flag.Usage = usage
	flag.StringVar(&gConf, "g", os.Getenv("SUMMER"), "Genelet Config")
	flag.StringVar(&sConf, "s", os.Getenv("AOFEI"), "Ssp Config")
	flag.BoolVar(&isLocal, "local", false, "local mode")
}

func main() {
	flag.Parse()
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	if err := run(ctx, flagWasSet("local")); err != nil {
		log.Fatal(err)
	}
}

func run(ctx context.Context, localFlagSet bool) error {
	logger, err := zap.NewDevelopment()
	if err != nil {
		return err
	}
	defer logger.Sync()

	sc, err := dsp.NewController(ctx, sConf)
	if err != nil {
		return err
	}
	defer sc.Close()
	sc.Logger = logger
	if err := applyLocalModeFlag(sc, localFlagSet, isLocal); err != nil {
		return err
	}

	gc, err := getGenelet(gConf, logger)
	if err != nil {
		return err
	}
	gc.DB = sc.DB
	gc.Storage["Redis"] = sc.Redis
	gc.Storage["Nc"] = sc.Nc
	gc.Storage["Spread"] = sc.C.Spread // pass the top to genelet, so it can use the same IO for local mode
	if gc.C.ServerPort == "" {
		gc.C.ServerPort = sc.C.ServerPort
	}
	if gc.C.ServerURL == "" {
		gc.C.ServerURL = sc.C.ServerURL
	}
	if gc.C.DocumentRoot == "" {
		gc.C.DocumentRoot = sc.C.DocumentRoot
	}
	if gc.C.ConnectArray == nil {
		gc.C.ConnectArray = sc.C.ConnectArray
	}

	mux := newServeMux(sc, gc)

	server := &http.Server{
		Addr:           ":" + sc.C.ServerPort,
		Handler:        mux,
		ReadTimeout:    15 * time.Second, // 15 seconds
		WriteTimeout:   15 * time.Second, // 15 seconds
		MaxHeaderBytes: 1 << 20,          // 1 MB
	}
	listener, err := net.Listen("tcp", server.Addr)
	if err != nil {
		return err
	}
	return runHTTPServer(ctx, server, listener, shutdownTimeout)
}

type gracefulHTTPServer interface {
	Serve(net.Listener) error
	Shutdown(context.Context) error
	Close() error
}

func runHTTPServer(ctx context.Context, server gracefulHTTPServer, listener net.Listener, timeout time.Duration) error {
	if server == nil || listener == nil {
		return fmt.Errorf("HTTP server and listener are required")
	}
	if timeout <= 0 {
		return fmt.Errorf("shutdown timeout must be positive")
	}
	serveErr := make(chan error, 1)
	go func() {
		serveErr <- server.Serve(listener)
	}()

	select {
	case err := <-serveErr:
		if errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		return err
	case <-ctx.Done():
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	shutdownErr := server.Shutdown(shutdownCtx)
	if shutdownErr != nil {
		closeErr := server.Close()
		err := <-serveErr
		if errors.Is(err, http.ErrServerClosed) {
			err = nil
		}
		return errors.Join(shutdownErr, closeErr, err)
	}
	err := <-serveErr
	if errors.Is(err, http.ErrServerClosed) {
		return nil
	}
	return err
}

func flagWasSet(name string) bool {
	found := false
	flag.Visit(func(f *flag.Flag) {
		if f.Name == name {
			found = true
		}
	})
	return found
}

func applyLocalModeFlag(sc *dsp.Controller, flagSet, enabled bool) error {
	if sc == nil || sc.C == nil || !flagSet {
		return nil
	}
	if sc.C.IsLocal == enabled {
		return nil
	}
	sc.C.IsLocal = enabled
	if enabled {
		return sc.ReloadLocalStaticCache()
	}
	return nil
}

func newServeMux(sc *dsp.Controller, geneletHandler http.Handler) *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("POST /bid/{domain}", sc.ServeBid)
	mux.HandleFunc("POST /pz", pzCORS(sc.ServeSSP))
	mux.HandleFunc("OPTIONS /pz", pzCORS(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))
	mux.HandleFunc("GET /win", sc.ServeWinLoss)
	mux.HandleFunc("GET /loss", sc.ServeWinLoss)
	mux.HandleFunc("GET /clk", sc.ServeWinLoss)
	mux.HandleFunc("GET /imp", sc.ServeWinLoss)
	mux.HandleFunc("GET /mid/win", sc.ServeMiddlemanCallback)
	mux.HandleFunc("GET /mid/loss", sc.ServeMiddlemanCallback)
	mux.HandleFunc("GET /mid/bill", sc.ServeMiddlemanCallback)
	mux.HandleFunc("GET /mid/click", sc.ServeMiddlemanCallback)
	mux.Handle("GET /debug/vars", expvar.Handler())
	mux.Handle("/", geneletHandler)
	return mux
}

func pzCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		next(w, r)
	}
}

func getGenelet(fn string, logger *zap.Logger) (*genelet.Controller, error) {
	c, err := genelet.NewConfig(fn)
	if err != nil {
		return nil, err
	}
	models, storage, filters, err := registry.BuildFactories(c.ProjectRoot, logger)
	if err != nil {
		return nil, err
	}

	return &genelet.Controller{
		C:                c,
		ModelFactories:   models,
		FilterFactories:  filters,
		StorageFactories: storage,
		Storage:          map[string]interface{}{},
		Logger:           logger,
	}, nil
}
