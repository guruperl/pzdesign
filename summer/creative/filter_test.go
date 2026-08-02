package creative

import (
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"github.com/guruperl/aofei/match"
)

func creativeFilterForPreset(values url.Values) *Filter {
	req := httptest.NewRequest("POST", "/creative", nil)
	req.Form = values
	filter := &Filter{}
	filter.Action = "insert"
	filter.Component = "creative"
	filter.RoleValue = "adv"
	filter.R = req
	return filter
}

func TestPresetPersistsStructuredNativeCreative(t *testing.T) {
	filter := creativeFilterForPreset(url.Values{
		"creative_name": {" Native One "}, "media_type": {"Native"}, "weight": {"2"},
		"w": {"1200"}, "h": {"627"}, "title": {"Title"}, "description": {"Description"},
		"cta": {"Learn more"}, "iconImg": {"https://cdn.example/icon.png"}, "mainImg": {"https://cdn.example/main.jpg"},
	})
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	if filter.R.Form.Get("media_type") != match.CreativeMediaNative || filter.R.Form.Get("weight") != "2.000000" {
		t.Fatalf("normalized form = %#v", filter.R.Form)
	}
	native, err := match.ParseNativeCreativeV1(filter.R.Form.Get("content"))
	if err != nil {
		t.Fatal(err)
	}
	if native.Title != "Title" || native.MainImageURL != "https://cdn.example/main.jpg" {
		t.Fatalf("native creative = %#v", native)
	}
}

func TestPresetRejectsInvalidNativeDataAndUnsafeURLs(t *testing.T) {
	values := url.Values{
		"creative_name": {"native"}, "media_type": {"Native"}, "weight": {"1"},
		"w": {"300"}, "h": {"250"}, "title": {"Title"}, "description": {"Description"},
		"cta": {"Open"}, "mainImg": {"javascript:alert(1)"},
	}
	if err := creativeFilterForPreset(values).Preset(); err == nil || !strings.Contains(err.Error(), "absolute HTTP(S)") {
		t.Fatalf("unsafe native image error = %v", err)
	}
	values.Set("mainImg", "https://cdn.example/main.png")
	values.Set("title", "")
	if err := creativeFilterForPreset(values).Preset(); err == nil || !strings.Contains(err.Error(), "title is required") {
		t.Fatalf("missing native title error = %v", err)
	}
}

func TestValidateCreativeSourceFormRejectsMarkupAndMIMEMismatch(t *testing.T) {
	for _, test := range []struct {
		mediaType string
		content   string
	}{
		{mediaType: "Banner", content: `<script>alert(1)</script>`},
		{mediaType: "Banner", content: "https://cdn.example/video.mp4"},
		{mediaType: "Video", content: "https://cdn.example/banner.html"},
		{mediaType: "Video", content: "javascript:alert(1)"},
	} {
		if err := validateCreativeSourceForm(url.Values{"media_type": {test.mediaType}, "content": {test.content}}); err == nil {
			t.Fatalf("%s source %q unexpectedly accepted", test.mediaType, test.content)
		}
	}
	for _, values := range []url.Values{
		{"media_type": {"Banner"}, "content": {"https://cdn.example/banner.html"}},
		{"media_type": {"Video"}, "content": {"https://cdn.example/video.mp4"}},
	} {
		if err := validateCreativeSourceForm(values); err != nil {
			t.Fatalf("valid source %#v: %v", values, err)
		}
	}
}
