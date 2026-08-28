// This is the combined web server for Summer/Genelet admin and Aofei DSP paths.
package main

import (
	"context"
	"database/sql"
	"errors"
	"expvar"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"path/filepath"
	"strconv"
	"strings"
	"sync/atomic"
	"syscall"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/guruperl/aofei/adminapi"
	"github.com/guruperl/aofei/dsp"
	"github.com/guruperl/aofei/hostedpayment"
	"github.com/guruperl/aofei/managementapi"
	"github.com/guruperl/aofei/trafficquality"
	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
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

const (
	languageCookieName   = "w8m_lang"
	languageCookieMaxAge = 365 * 24 * 60 * 60
)

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
	if err := adminapi.SetUploadedAudienceTTL(sc.C.PrivacyAudienceTTLSeconds); err != nil {
		return err
	}
	if err := applyLocalModeFlag(sc, localFlagSet, isLocal); err != nil {
		return err
	}

	gc, err := getGenelet(gConf, logger)
	if err != nil {
		return err
	}
	gc.DB = sc.DB
	publicAccountProtector, err := summer.NewPublicAccountProtectorFromEnv(sc.Redis)
	if err != nil {
		return fmt.Errorf("initialize public account protection: %w", err)
	}
	if publicAccountProtector != nil {
		gc.Storage[summer.PublicAccountProtectorStorageKey] = publicAccountProtector
	}
	gc.Storage[summer.ActionReportingStorageKey] = actionReportingAvailable(ctx, sc.DB)
	gc.Storage[summer.MarketplaceReportingStorageKey] = marketplaceReportingAvailable(ctx, sc.DB)
	identity, err := genelet.NewIdentityService(gc.C, gc.DB)
	if err != nil {
		return fmt.Errorf("initialize identity security: %w", err)
	}
	gc.Identity = identity
	gc.Storage["Identity"] = identity
	publisherAuthService := sc.PublisherAuthService()
	if publisherAuthService != nil && identity == nil {
		return fmt.Errorf("direct SSP publisher authentication requires the Summer identity boundary")
	}
	gc.Storage["PublisherAuth"] = publisherAuthService
	gc.Storage[summer.DirectSSPTokenIssuerStorageKey] = sc.DirectSSPTokenIssuer()
	apiService, err := managementapi.NewService(sc.C.ManagementAPI, sc.DB, sc.Redis)
	if err != nil {
		return fmt.Errorf("initialize management API: %w", err)
	}
	if apiService != nil && identity == nil {
		return fmt.Errorf("management API requires the Summer identity boundary")
	}
	gc.Storage["ManagementAPI"] = apiService
	qualityService, err := trafficquality.NewService(sc.C.TrafficQuality, sc.DB)
	if err != nil {
		return fmt.Errorf("initialize traffic-quality review: %w", err)
	}
	if qualityService != nil && identity == nil {
		return fmt.Errorf("traffic-quality review requires the Summer identity boundary")
	}
	gc.Storage["TrafficQuality"] = qualityService
	paymentService, err := hostedpayment.NewService(sc.C.HostedPayments, sc.DB)
	if err != nil {
		return fmt.Errorf("initialize hosted payments: %w", err)
	}
	if paymentService != nil && identity == nil {
		return fmt.Errorf("hosted payments require the Summer identity boundary")
	}
	storeHostedPayment(gc.Storage, paymentService)
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

	health := newServiceHealth(sc)
	mux := newServeMuxWithServices(sc, gc, health, apiService, paymentService)

	server := &http.Server{
		Addr:              ":" + sc.C.ServerPort,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
		MaxHeaderBytes:    1 << 20,
	}
	listener, err := net.Listen("tcp", server.Addr)
	if err != nil {
		return err
	}
	health.accepting.Store(true)
	return runHTTPServer(ctx, server, listener, shutdownTimeout, func() {
		health.accepting.Store(false)
	})
}

const marketplaceReportingSchemaQuery = `SELECT COUNT(DISTINCT table_name)
FROM information_schema.tables
WHERE table_schema=DATABASE()
  AND table_name IN ('report_delivery','measurement_action','mid_callback_retry','daily_log')`

const actionReportingSchemaQuery = `SELECT COUNT(*)
FROM information_schema.tables
WHERE table_schema=DATABASE() AND table_name='measurement_action'`

func actionReportingAvailable(ctx context.Context, db *sql.DB) bool {
	return schemaQueryMatches(ctx, db, actionReportingSchemaQuery, 1)
}

func marketplaceReportingAvailable(ctx context.Context, db *sql.DB) bool {
	return schemaQueryMatches(ctx, db, marketplaceReportingSchemaQuery, 4)
}

func schemaQueryMatches(ctx context.Context, db *sql.DB, query string, want int) bool {
	if db == nil {
		return false
	}
	checkCtx, cancel := context.WithTimeout(ctx, 2*time.Second)
	defer cancel()
	var tableCount int
	if err := db.QueryRowContext(checkCtx, query).Scan(&tableCount); err != nil {
		return false
	}
	return tableCount == want
}

func storeHostedPayment(storage map[string]interface{}, service *hostedpayment.Service) {
	if service == nil {
		delete(storage, "HostedPayment")
		return
	}
	storage["HostedPayment"] = service
}

type serviceHealth struct {
	controller *dsp.Controller
	accepting  atomic.Bool
}

func newServiceHealth(controller *dsp.Controller) *serviceHealth {
	return &serviceHealth{controller: controller}
}

func (h *serviceHealth) live(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Cache-Control", "no-store")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(http.StatusNoContent)
}

func (h *serviceHealth) ready(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Cache-Control", "no-store")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	if h == nil || !h.accepting.Load() || h.controller == nil || h.controller.ServingReadiness(time.Now()) != nil {
		http.Error(w, "service unavailable", http.StatusServiceUnavailable)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

type gracefulHTTPServer interface {
	Serve(net.Listener) error
	Shutdown(context.Context) error
	Close() error
}

func runHTTPServer(ctx context.Context, server gracefulHTTPServer, listener net.Listener, timeout time.Duration, beforeShutdown ...func()) error {
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
	for _, callback := range beforeShutdown {
		if callback != nil {
			callback()
		}
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
		if err := sc.ReloadLocalStaticCache(); err != nil {
			return err
		}
		sc.StartLocalStaticCacheReload()
	} else {
		sc.StopLocalStaticCacheReload()
	}
	return nil
}

func newServeMux(sc *dsp.Controller, geneletHandler http.Handler, healthStates ...*serviceHealth) *http.ServeMux {
	var health *serviceHealth
	if len(healthStates) != 0 {
		health = healthStates[0]
	}
	return newServeMuxWithManagementAPI(sc, geneletHandler, health, nil)
}

func newServeMuxWithManagementAPI(sc *dsp.Controller, geneletHandler http.Handler, suppliedHealth *serviceHealth, apiService *managementapi.Service) *http.ServeMux {
	return newServeMuxWithServices(sc, geneletHandler, suppliedHealth, apiService, nil)
}

func newServeMuxWithServices(sc *dsp.Controller, geneletHandler http.Handler, suppliedHealth *serviceHealth, apiService *managementapi.Service, paymentService *hostedpayment.Service) *http.ServeMux {
	docRoot := ""
	if gc, ok := geneletHandler.(*genelet.Controller); ok {
		docRoot = gc.C.DocumentRoot
	}
	mux := http.NewServeMux()
	health := newServiceHealth(sc)
	health.accepting.Store(true)
	if suppliedHealth != nil {
		health = suppliedHealth
	}
	traffic := dsp.NewTrafficGate(sc.C)
	mux.HandleFunc("POST /bid/{domain}", traffic.Handler("adx", func(r *http.Request) string {
		return "adx:" + r.PathValue("domain")
	}, sc.ServeBid))
	mux.HandleFunc("POST /pz", pzCORS(traffic.Handler("ssp", func(*http.Request) string {
		return "ssp"
	}, sc.ServeSSP)))
	mux.HandleFunc("OPTIONS /pz", pzCORS(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))
	mux.HandleFunc("GET /win", sc.ServeWinLoss)
	mux.HandleFunc("GET /loss", sc.ServeWinLoss)
	mux.HandleFunc("GET /clk", sc.ServeWinLoss)
	mux.HandleFunc("GET /imp", sc.ServeWinLoss)
	mux.HandleFunc("POST /action", sc.ServeAction)
	mux.HandleFunc("GET /mid/win", sc.ServeMiddlemanCallback)
	mux.HandleFunc("GET /mid/loss", sc.ServeMiddlemanCallback)
	mux.HandleFunc("GET /mid/bill", sc.ServeMiddlemanCallback)
	mux.HandleFunc("GET /mid/click", sc.ServeMiddlemanCallback)
	mux.Handle("GET /debug/vars", sc.MetricsHandler(expvar.Handler()))
	mux.HandleFunc("GET /healthz", health.live)
	mux.HandleFunc("GET /readyz", health.ready)
	if apiService != nil {
		mux.Handle("/api/v1/", apiService.Handler())
	} else {
		mux.Handle("/api/", http.NotFoundHandler())
	}
	if paymentService != nil {
		mux.Handle("POST /webhooks/stripe", paymentService.WebhookHandler())
	}
	mux.Handle("/webhooks/", http.NotFoundHandler())
	mux.Handle("/", frontPageWrapper(geneletHandler, docRoot))
	return mux
}

func frontPageWrapper(next http.Handler, docRoot string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" && r.URL.Path == "/" {
			serveFrontPage(w, r, docRoot, negotiateLanguage(r), true)
			return
		}
		if r.Method == "GET" && (r.URL.Path == "/index.html" || r.URL.Path == "/index.en.html") {
			lang := "zh"
			if r.URL.Path == "/index.en.html" {
				lang = "en"
			}
			serveFrontPage(w, r, docRoot, lang, false)
			return
		}
		if r.Method == "GET" && (r.URL.Path == "/goto/web/g/" || r.URL.Path == "/goto/web/e/") {
			lang := "zh"
			if r.URL.Path == "/goto/web/e/" {
				lang = "en"
			}
			setLanguagePreference(w, lang)
			serveFrontPage(w, r, docRoot, lang, false)
			return
		}
		if r.Method == "GET" && (r.URL.Path == "/language/zh" || r.URL.Path == "/language/en") {
			lang := strings.TrimPrefix(r.URL.Path, "/language/")
			setLanguagePreference(w, lang)
			w.Header().Set("Cache-Control", "private, no-store")
			http.Redirect(w, r, languageReturnTarget(r.URL.Query().Get("return"), lang), http.StatusSeeOther)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func serveFrontPage(w http.ResponseWriter, r *http.Request, docRoot, lang string, negotiated bool) {
	filename := "index.html"
	actualLanguage := "zh"
	if lang == "en" {
		filename = "index.en.html"
		actualLanguage = "en"
	}
	filePath := filepath.Join(docRoot, filename)
	if _, err := os.Stat(filePath); err != nil && lang == "en" {
		filename = "index.html"
		actualLanguage = "zh"
		filePath = filepath.Join(docRoot, filename)
	}
	if negotiated {
		w.Header().Set("Vary", "Accept-Language, Cookie")
	}
	w.Header().Set("Cache-Control", "private, no-cache")
	w.Header().Set("Content-Language", actualLanguage)
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	file, err := os.Open(filePath)
	if err != nil {
		http.NotFound(w, r)
		return
	}
	defer file.Close()
	info, err := file.Stat()
	if err != nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}
	http.ServeContent(w, r, filename, info.ModTime(), file)
}

func setLanguagePreference(w http.ResponseWriter, lang string) {
	http.SetCookie(w, &http.Cookie{
		Name:     languageCookieName,
		Value:    lang,
		Path:     "/",
		MaxAge:   languageCookieMaxAge,
		Expires:  time.Now().Add(languageCookieMaxAge * time.Second).UTC(),
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteLaxMode,
	})
}

func languageReturnTarget(raw, lang string) string {
	chartag := "g"
	if lang == "en" {
		chartag = "e"
	}
	fallback := "/goto/web/" + chartag + "/"
	parsed, err := url.Parse(raw)
	if err != nil || parsed.IsAbs() || parsed.Host != "" || parsed.User != nil || parsed.Opaque != "" {
		return fallback
	}
	if !strings.HasPrefix(parsed.Path, fallback) {
		return fallback
	}
	for _, segment := range strings.Split(parsed.Path, "/") {
		if segment == "." || segment == ".." {
			return fallback
		}
	}
	return parsed.String()
}

func negotiateLanguage(r *http.Request) string {
	cookie, err := r.Cookie(languageCookieName)
	if err == nil && cookie.Value != "" {
		if cookie.Value == "en" || cookie.Value == "zh" {
			return cookie.Value
		}
	}
	acceptLang := r.Header.Get("Accept-Language")
	if len(acceptLang) > 0 {
		// Parse Accept-Language header with q-values (weighted tags).
		// Format: en-US,en;q=0.9,zh;q=0.8 — split by comma, parse each tag and q-value.
		// When weights tie, prefer whichever tag appeared first in the header.
		type langPref struct {
			weight float64
			order  int
		}
		enPref := langPref{order: -1}
		zhPref := langPref{order: -1}
		order := 0
		for _, tag := range strings.Split(acceptLang, ",") {
			tag = strings.TrimSpace(tag)
			if len(tag) == 0 {
				continue
			}
			q := 1.0
			valid := true
			if parts := strings.Split(tag, ";"); len(parts) > 1 {
				tag = parts[0]
				for _, param := range parts[1:] {
					key, value, found := strings.Cut(strings.TrimSpace(param), "=")
					if !found || !strings.EqualFold(strings.TrimSpace(key), "q") {
						continue
					}
					parsed, err := strconv.ParseFloat(strings.TrimSpace(value), 64)
					if err != nil || parsed < 0 || parsed > 1 {
						valid = false
						break
					}
					q = parsed
				}
				if !valid || q == 0 {
					order++
					continue
				}
			}
			tag = strings.ToLower(strings.TrimSpace(tag))
			// Match primary language tag (before hyphen)
			primary := tag
			if idx := strings.Index(tag, "-"); idx > 0 {
				primary = tag[:idx]
			}
			if primary == "en" && (q > enPref.weight || (q == enPref.weight && enPref.order == -1)) {
				enPref = langPref{weight: q, order: order}
			} else if primary == "zh" && (q > zhPref.weight || (q == zhPref.weight && zhPref.order == -1)) {
				zhPref = langPref{weight: q, order: order}
			}
			order++
		}
		// Compare: higher weight wins; if tied, earlier order wins
		if enPref.weight > zhPref.weight {
			return "en"
		}
		if zhPref.weight > enPref.weight {
			return "zh"
		}
		// Weights are equal; prefer whichever appeared first
		if enPref.order >= 0 && (zhPref.order == -1 || enPref.order < zhPref.order) {
			return "en"
		}
		if zhPref.order >= 0 {
			return "zh"
		}
	}
	return "en"
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
