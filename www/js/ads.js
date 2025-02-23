function pzLoadAds(data) {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			var resps = JSON.parse(this.responseText);
			for (var i in data.adUnits) {
				let adunit=data.adUnits[i]
				document.getElementById(adunit.code).innerHTML = resps[i]
			}
		} else if (this.status != 200) {
			for (var i in data.adUnits) {
				let adunit=data.adUnits[i]
				document.getElementById(adunit.code).innerHTML = "Ad Request Failed"
			}
		}
	};
	let url = "/pz";
	xhttp.open("POST", url, true);
	xhttp.setRequestHeader("Content-Type", "application/json");
	xhttp.withCredentials = "true";
	xhttp.send(JSON.stringify(data)); 
}
