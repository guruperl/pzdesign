// Package creative implements creative modules, including uploading
package creative

import (
	"fmt"
	"io"
	"math"
	"mime"
	"net/http"
	"net/url"
	"os"
	"path"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/guruperl/aofei/match"
	"github.com/guruperl/pzdesign/summer"
)

type Filter struct {
	summer.Filter
}

func (self *Filter) Preset() error {
	if err := self.Filter.Preset(); err != nil {
		return err
	}

	ARGS := self.R.Form
	action := self.Action
	if action == "insert" || action == "update" {
		if err := summer.SetSizeID(ARGS); err != nil {
			return err
		}
		mediaType := strings.TrimSpace(ARGS.Get("media_type"))
		if mediaType == "" {
			switch ARGS.Get("randomChoice") {
			case "3":
				mediaType = match.CreativeMediaVideo
			case "4":
				mediaType = match.CreativeMediaNative
			default:
				mediaType = match.CreativeMediaBanner
			}
		}
		switch mediaType {
		case match.CreativeMediaBanner, match.CreativeMediaVideo, match.CreativeMediaNative:
			ARGS.Set("media_type", mediaType)
		default:
			return fmt.Errorf("media_type must be Banner, Video, or Native")
		}
		weight, err := strconv.ParseFloat(strings.TrimSpace(ARGS.Get("weight")), 64)
		if err != nil || weight <= 0 || math.IsNaN(weight) || math.IsInf(weight, 0) {
			return fmt.Errorf("creative weight must be a finite positive value")
		}
		ARGS.Set("weight", strconv.FormatFloat(weight, 'f', 6, 64))
		ARGS.Set("creative_name", strings.TrimSpace(ARGS.Get("creative_name")))
		if mediaType == match.CreativeMediaNative {
			for _, field := range []string{"iconImg", "mainImg"} {
				if ARGS.Get(field) == "" && field == "iconImg" {
					continue
				}
				if err := validateCreativeSourceURL(field, ARGS.Get(field)); err != nil {
					return err
				}
			}
			content, err := match.MarshalNativeCreativeV1(match.NativeCreativeV1{
				Version: "1", Title: strings.TrimSpace(ARGS.Get("title")),
				Description: strings.TrimSpace(ARGS.Get("description")), CTA: strings.TrimSpace(ARGS.Get("cta")),
				IconURL: strings.TrimSpace(ARGS.Get("iconImg")), MainImageURL: strings.TrimSpace(ARGS.Get("mainImg")),
			})
			if err != nil {
				return err
			}
			ARGS.Set("content", content)
		}
	}

	return nil
}

func (self *Filter) Before(model *Model, extra url.Values, nextextra url.Values) error {
	if err := self.Filter.Before(&model.Model, extra, nextextra); err != nil {
		return err
	}

	ARGS := self.R.Form
	action := self.Action

	if action == "topics" {
		extra.Set("item_id", self.R.Form.Get("item_id"))
	} else if action == "insert" || action == "update" {
		if mediaType := ARGS.Get("media_type"); (mediaType == match.CreativeMediaBanner || mediaType == match.CreativeMediaVideo) && ARGS.Get("media_1") != "" {
			itemID := ARGS.Get("item_id")
			dir := filepath.Join(self.C.UploadDir, itemID)
			if _, err := os.Stat(dir); os.IsNotExist(err) {
				if err = os.MkdirAll(dir, 0755); err != nil {
					return err
				}
			}
			file, err := summer.CleanUploadName(ARGS.Get("media_1"))
			if err != nil {
				return err
			}
			if err := self.uploading(dir, itemID, file, "1"); err != nil {
				return err
			}
		}
		if err := validateCreativeSourceForm(ARGS); err != nil {
			return err
		}
	}

	return nil
}

func (self *Filter) After(model *Model) error {
	if err := self.Filter.After(&model.Model); err != nil {
		return err
	}

	ARGS := self.R.Form
	action := self.Action
	//who := self.RoleValue
	lists := *model.LISTS
	//other := *model.OTHER

	if action == "insert" && ARGS.Get("media") != "" {
		for i, m := range ARGS["media"] {
			if err := model.DoSQL(`
INSERT INTO adv_media (creative_id, series, media, disk, mime, created)
VALUES (?,?,?,?,?,NOW())`,
				lists[0]["creative_id"], ARGS["series"][i], m, ARGS["disk"][i], ARGS["mime"][i]); err != nil {
				return err
			}
		}
	} else if action == "topics" {
		for _, item := range lists {
			summer.SetWH(item)
			item["is_native"] = item["media_type"] == match.CreativeMediaNative
			if item["is_native"] == true {
				if content, ok := item["content"].(string); ok {
					if native, err := match.ParseNativeCreativeV1(content); err == nil {
						item["native_title"] = native.Title
						item["native_description"] = native.Description
						item["native_cta"] = native.CTA
						item["native_icon_url"] = native.IconURL
						item["native_main_image_url"] = native.MainImageURL
					}
				}
			}
		}
	}

	return nil
}

func (self *Filter) uploading(dir, itemID, file, series string) error {
	ARGS := self.R.Form

	file, err := summer.CleanUploadName(file)
	if err != nil {
		return err
	}
	fh, err := os.Open(filepath.Join(self.C.UploadDir, file))
	if err != nil {
		return err
	}
	defer fh.Close()

	buffer := make([]byte, 512)
	_, err = fh.Read(buffer)
	if err != nil && err != io.EOF {
		return err
	}
	mime := http.DetectContentType(buffer)
	if ARGS.Get("media_type") == match.CreativeMediaVideo && mime == "application/octet-stream" {
		arrs := strings.Split(file, ".")
		popular := map[string]string{
			"m3u": "application/x-mpegURL", "m3u8": "application/x-mpegURL",
			"flv": "video/x-flv", "mp4": "video/mp4", "ogg": "video/ogg",
			"webm": "video/webm", "m4v": "video/x-m4v", "ts": "video/MP2T",
			"3gp": "video/3gpp", "mov": "video/quicktime", "avi": "video/x-msvideo",
			"asf": "video/ms-asf", "wma": "video/ms-asf", "wmv": "video/x-ms-wmv"}
		if m, ok := popular[strings.ToLower(arrs[len(arrs)-1])]; ok {
			mime = m
		}
	}
	if ARGS.Get("media_type") == match.CreativeMediaBanner && !strings.HasPrefix(mime, "image/") {
		return fmt.Errorf("uploaded banner creative must be an image; detected MIME %q", mime)
	}
	if ARGS.Get("media_type") == match.CreativeMediaVideo && !strings.HasPrefix(mime, "video/") && mime != "application/x-mpegURL" && mime != "application/vnd.apple.mpegurl" {
		return fmt.Errorf("uploaded video creative has unsupported MIME %q", mime)
	}

	dest := filepath.Join(dir, file)
	err = os.Rename(filepath.Join(self.C.UploadDir, file), dest)
	if err != nil {
		return err
	}

	media := self.C.UploadURL + "/" + itemID + "/" + file
	ARGS.Add("mime", mime)
	ARGS.Add("series", series)
	ARGS.Add("media", media)
	ARGS.Add("disk", dest)
	ARGS.Set("content", media)

	return nil
}

func validateCreativeSourceForm(args url.Values) error {
	mediaType := args.Get("media_type")
	if mediaType == match.CreativeMediaNative {
		_, err := match.ParseNativeCreativeV1(args.Get("content"))
		return err
	}
	raw := strings.TrimSpace(args.Get("content"))
	if err := validateCreativeSourceURL("content", raw); err != nil {
		return err
	}
	u, _ := url.Parse(raw)
	ext := strings.ToLower(path.Ext(u.Path))
	detected := strings.ToLower(strings.Split(mime.TypeByExtension(ext), ";")[0])
	if ext == ".htm" || ext == ".html" {
		detected = "text/html"
	}
	if ext == ".m3u" || ext == ".m3u8" {
		detected = "application/vnd.apple.mpegurl"
	}
	switch mediaType {
	case match.CreativeMediaBanner:
		if detected != "text/html" && !strings.HasPrefix(detected, "image/") {
			return fmt.Errorf("banner content URL must identify HTML or an image; detected MIME %q", detected)
		}
	case match.CreativeMediaVideo:
		if !strings.HasPrefix(detected, "video/") && detected != "application/x-mpegurl" && detected != "application/vnd.apple.mpegurl" {
			return fmt.Errorf("video content URL has unsupported MIME %q", detected)
		}
	}
	return nil
}

func validateCreativeSourceURL(name, raw string) error {
	u, err := url.Parse(strings.TrimSpace(raw))
	if err != nil {
		return fmt.Errorf("%s URL: %w", name, err)
	}
	scheme := strings.ToLower(u.Scheme)
	if (scheme != "http" && scheme != "https") || u.Hostname() == "" || u.User != nil {
		return fmt.Errorf("%s URL must be an absolute HTTP(S) URL without credentials", name)
	}
	return nil
}
