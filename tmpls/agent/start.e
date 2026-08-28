{{ define "header" }}
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="/admin/favicon.ico">

    <title>W8M Agency Review</title>

    <!-- Bootstrap core CSS -->
    <link href="/admin/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="/admin/dashboard.css?v=20260828-1" rel="stylesheet">
<style>
html, body {
  font-family: "SimSun";
}
h1, h2, h3, h4, h5, h6, button {
  font-family: "Microsoft YaHei","SimHei";
}
.nav {
  font-family: "Microsoft YaHei","SimHei";
}
</style>
  </head>

  <body>
    <nav class="navbar navbar-dark sticky-top bg-dark flex-md-nowrap p-0">
      <a class="navbar-brand col-sm-3 col-md-2 mr-0" href="#">Agency Review</a>
    <div class="navbar-brand">
&nbsp; Welcome, <em>{{index .ARGS.agent_login 0}}</em>; Access Level: <em>{{index .ARGS.agent_level 0}}</em> &nbsp;
    </div>
      <ul class="navbar-nav px-3">
        <li class="nav-item text-nowrap"><a class="nav-link" href="security?action=dashboard">Account Security</a></li>
        <li class="nav-item text-nowrap">
          <form method="post" action="logout"><button class="btn btn-link nav-link" type="submit">Sign Out</button></form>
        </li>
      </ul>
    </nav>

    <div class="container-fluid">
      <div class="row">
        <nav class="col-md-2 d-none d-md-block bg-light sidebar">
          <div class="sidebar-sticky">
            <ul class="nav flex-column">
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `adv` }} active{{end}}" href="adv?action=topics">
                  Advertiser Accounts {{ if eq .Other.Component "adv" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `campaign` }} active{{end}}" href="campaign?action=topics">
                  Campaigns {{ if eq .Other.Component "campaign" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
            </ul>

          </div>
        </nav>

        <main role="main" class="col-md-9 ml-sm-auto col-lg-10 pt-3 px-4">

{{ end }}
