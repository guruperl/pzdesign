function loadAds(data) {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			var resps = JSON.parse(this.responseText);
			for (resp in resps) {
				document.getElementById(resp.code).innerHTML = resp.html
			}
		} else if (this.status != 200) {
			for (var i in data.adUnits) {
				let adunit=data.adUnits[i]
				document.getElementById(adunit.code).innerHTML = "Ad Request Failed"
			}
		}
	};
	let url = "/pz"+data.site_id.toString();
	xhttp.open("POST", url, true);
	xhttp.withCredentials = "true";
	xhttp.send(JSON.stringify(data)); 
}
