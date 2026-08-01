package main

import "testing"

func TestHasAssembledQuery(t *testing.T) {
	tests := []struct {
		name string
		text string
		want bool
	}{
		{
			name: "quoted query",
			text: `{{$query := print "campaign_id=" .campaign_id "&campaign_md5=" .campaign_md5}}`,
			want: true,
		},
		{
			name: "raw quoted query",
			text: "{{print `site_id=` .site_id `&site_md5=` .site_md5}}",
			want: true,
		},
		{
			name: "direct parameters",
			text: `<a href="item?action=topics&campaign_id={{.campaign_id}}&campaign_md5={{.campaign_md5}}">`,
			want: false,
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := hasAssembledQuery([]byte(test.text)); got != test.want {
				t.Fatalf("hasAssembledQuery() = %v, want %v", got, test.want)
			}
		})
	}
}
