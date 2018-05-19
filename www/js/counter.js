$(document).ready(function() {
  $("button[aria-label='Close']").click(function() {
    var badge = $("span[class='badge badge-pill badge-danger']")
    var count = Number(badge.text());
	if (count==1) {
      badge.remove();
      $("div[class='dropdown-header text-center']").parent().remove();
	} else {
      badge.text(count-1);
	}
  });
});
