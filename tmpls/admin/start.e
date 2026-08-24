{{ define "header" }}
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="/admin/favicon.ico">

    <title>W8M Administrative Management</title>

    <!-- Bootstrap core CSS -->
    <link href="/admin/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="/admin/dashboard.css" rel="stylesheet">
  </head>

  <body>
    <nav class="navbar navbar-dark sticky-top bg-dark flex-md-nowrap p-0">
      <a class="navbar-brand col-sm-3 col-md-2 mr-0" href="#">Administrator</a>
    <div class="navbar-brand">
Welcome&nbsp; <em>{{index .ARGS.admin_login 0}}</em> ! Your ID&nbsp; <em>{{index .ARGS.admin_id 0}}</em>.
	</div>
      <ul class="navbar-nav px-3">
        <li class="nav-item text-nowrap"><a class="nav-link" href="security?action=dashboard">Account security</a></li>
        <li class="nav-item text-nowrap"><form method="post" action="logout"><button class="btn btn-link nav-link" type="submit">Sign out</button></form></li>
      </ul>
    </nav>

    <div class="container-fluid">
      <div class="row">
        <nav class="col-md-2 d-none d-md-block bg-light sidebar">
          <div class="sidebar-sticky">
            <ul class="nav flex-column">
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `agent` }} active{{end}}" href="agent?action=topics">
                  Agents {{ if eq .Other.Component "agent" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `adv` }} active{{end}}" href="adv?action=topics">
                  Advertisers {{ if eq .Other.Component "adv" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `pub` }} active{{end}}" href="pub?action=topics">
                  Publishers {{ if eq .Other.Component "pub" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `campaign` }} active{{end}}" href="campaign?action=topics">
                  Campaigns {{ if eq .Other.Component "campaign" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `apicredential` }} active{{end}}" href="apicredential?action=topics">
                  Management API credentials
                </a>
              </li>
              {{if .Other.PublisherAuthEnabled}}<li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `publishercredential` }} active{{end}}" href="publishercredential?action=topics">
                  Publisher request credentials
                </a>
              </li>{{end}}
              {{if .Other.HostedPaymentEnabled}}<li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `hostedpayment` }} active{{end}}" href="hostedpayment?action=topics">
                  Hosted funding and payouts
                </a>
              </li>{{end}}
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `site` }} active{{end}}" href="site?action=topics">
                  Sites {{ if eq .Other.Component "site" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
            </ul>

          </div>
        </nav>

        <main role="main" class="col-md-9 ml-sm-auto col-lg-10 pt-3 px-4">

{{ end }}
