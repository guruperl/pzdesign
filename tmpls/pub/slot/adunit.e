<pre>
&lt;html&gt;
&lt;head&gt;
&lt;script src=&quot;/js/ads.js&quot;&gt;&lt;/script&gt;
&lt;/head&gt;
&lt;body&gt;
...
&lt;div id=&quot;pz-{{index .ARGS.site_id 0}}-{{index .ARGS.slot_id 0}}&quot;&gt;&lt;/div&gt;
...
&lt;/body&gt;
&lt;script&gt;
loadAds({
	site_id: {{index .ARGS.site_id 0}},
	adUnits: [{
		code: 'pz-{{index .ARGS.site_id 0}}-{{index .ARGS.slot_id 0}}',
		slot_id: {{index .ARGS.slot_id 0}},
		mediaTypes: {
			{{index .ARGS.mediaType 0}}: { sizes:[{{index .ARGS.w 0}}, {{index .ARGS.h 0}}] }
		}
	}]
})
&lt;/script&gt;
&lt;/html&gt;
</pre>
