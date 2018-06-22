function setInnerHtml(id, html) {
  var elm = document.getElementById(id);
  elm.innerHTML = html;
  var scripts = elm.getElementsByTagName("script");
  // If we don't clone the results then "scripts"
  // will actually update live as we insert the new
  // tags, and we'll get caught in an endless loop
  var scriptsClone = [];
  for (var i = 0; i < scripts.length; i++) {
    scriptsClone.push(scripts[i]);
  }
  for (var i = 0; i < scriptsClone.length; i++) {
    var currentScript = scriptsClone[i];
    var s = document.createElement("script");
    // Copy all the attributes from the original script
    for (var j = 0; j < currentScript.attributes.length; j++) {
      var a = currentScript.attributes[j];
      s.setAttribute(a.name, a.value);
    }
    s.appendChild(document.createTextNode(currentScript.innerHTML));
    currentScript.parentNode.replaceChild(s, currentScript);
  }
}

function insertHtml(id, html) {  
   var ele = document.getElementById(id);  
   ele.innerHTML = html;  
   var codes = ele.getElementsByTagName("script");   
   for(var i=0;i<codes.length;i++) {  
       eval(codes[i].text);  
   }  
}

function pzLoadAds(data) {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			var resps = JSON.parse(this.responseText);
			for (var i in data.adUnits) {
				let adunit=data.adUnits[i]
				//insertHtml(adunit.code, resps[i])
				setInnerHtml(adunit.code, resps[i])
				//document.getElementById(adunit.code).innerHTML = resps[i]
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
