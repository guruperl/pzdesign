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
			target.innerHTML = ok ? (resps[i] || "") : "Ad Request Failed";
		}
	};
	var url = pzAdEndpoint(options);
	xhttp.open("POST", url, true);
	xhttp.setRequestHeader("Content-Type", "application/json");
	xhttp.send(JSON.stringify(data)); 
}
