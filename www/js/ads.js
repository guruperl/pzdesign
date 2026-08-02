function pzAdEndpoint(options) {
	if (options && options.endpoint) {
		return options.endpoint;
	}
	var script = document.currentScript && document.currentScript.src ? document.currentScript : null;
	var scripts = document.getElementsByTagName("script");
	if (!script) {
		for (var i = scripts.length - 1; i >= 0; i--) {
			if (scripts[i].src && scripts[i].src.indexOf("/ads.js") >= 0) {
				script = scripts[i];
				break;
			}
		}
	}
	if (!script) {
		for (var j = scripts.length - 1; j >= 0; j--) {
			if (scripts[j].src) {
				script = scripts[j];
				break;
			}
		}
	}
	if (script && script.src) {
		var anchor = document.createElement("a");
		anchor.href = script.src;
		if (anchor.protocol && anchor.host) {
			return anchor.protocol + "//" + anchor.host + "/pz";
		}
	}
	return "/pz";
}

function pzLoadAds(data, options) {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
		if (this.readyState != 4) {
			return;
		}
		var ok = this.status == 200;
		var resps = [];
		if (ok) {
			try {
				resps = JSON.parse(this.responseText);
				ok = Array.isArray(resps);
			} catch (err) {
				ok = false;
			}
		}
		for (var i = 0; i < data.adUnits.length; i++) {
			var adunit = data.adUnits[i];
			var target = document.getElementById(adunit.code);
			if (!target) {
				continue;
			}
			pzRenderAd(target, ok ? resps[i] : "", adunit, ok ? "no-fill" : "error");
		}
	};
	var url = pzAdEndpoint(options);
	xhttp.open("POST", url, true);
	xhttp.timeout = options && options.timeout ? options.timeout : 3000;
	xhttp.setRequestHeader("Content-Type", "application/json");
	xhttp.send(JSON.stringify(data));
}

function pzRenderAd(target, markup, adunit, emptyState) {
	while (target.firstChild) {
		target.removeChild(target.firstChild);
	}
	if (typeof markup !== "string" || markup.length === 0) {
		target.setAttribute("data-pz-state", emptyState || "no-fill");
		return;
	}
	var frame = document.createElement("iframe");
	frame.setAttribute("title", "Advertisement");
	frame.setAttribute("sandbox", "allow-scripts allow-forms allow-popups allow-popups-to-escape-sandbox");
	frame.setAttribute("referrerpolicy", "no-referrer");
	frame.setAttribute("scrolling", "no");
	frame.setAttribute("frameborder", "0");
	frame.style.border = "0";
	frame.style.display = "block";
	var banner = adunit && adunit.mediaTypes && adunit.mediaTypes.banner;
	if (banner && banner.size && banner.size.length === 2) {
		frame.width = String(banner.size[0]);
		frame.height = String(banner.size[1]);
	} else {
		frame.style.width = "100%";
		frame.style.height = "100%";
	}
	frame.srcdoc = markup;
	target.appendChild(frame);
	target.setAttribute("data-pz-state", "filled");
}
