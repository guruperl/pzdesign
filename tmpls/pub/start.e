{{define "header"}}
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="Publisher - PzAdx">
  <meta name="keyword" content="publisher, eic">
  <meta name="msapplication-TileImage" content="http://www.eic.co/wp-content/uploads/2018/01/cropped-site_icon-270x270.jpg" />
  <title>PzAdx Publisher - Guaranteeing Maximal Income</title>

  <!-- Icons -->
  <link href="/1.0.8/vendors/css/flag-icon.min.css" rel="stylesheet">
  <link href="/1.0.8/vendors/css/font-awesome.min.css" rel="stylesheet">
  <link href="/1.0.8/vendors/css/simple-line-icons.min.css" rel="stylesheet">

  <!-- Main styles for this application -->
  <link href="/1.0.8/css/style.css" rel="stylesheet">

  <!-- Styles required by this views -->
  <link href="/1.0.8/vendors/css/daterangepicker.min.css" rel="stylesheet">
  <link href="/1.0.8/vendors/css/gauge.min.css" rel="stylesheet">
  <link href="/1.0.8/vendors/css/toastr.min.css" rel="stylesheet">

</head>

<!-- BODY options, add following classes to body to change options

// Header options
1. '.header-fixed'					- Fixed Header

// Brand options
1. '.brand-minimized'       - Minimized brand (Only symbol)

// Sidebar options
1. '.sidebar-fixed'					- Fixed Sidebar
2. '.sidebar-hidden'				- Hidden Sidebar
3. '.sidebar-off-canvas'		- Off Canvas Sidebar
4. '.sidebar-minimized'			- Minimized Sidebar (Only icons)
5. '.sidebar-compact'			  - Compact Sidebar

// Aside options
1. '.aside-menu-fixed'			- Fixed Aside Menu
2. '.aside-menu-hidden'			- Hidden Aside Menu
3. '.aside-menu-off-canvas'	- Off Canvas Aside Menu

// Breadcrumb options
1. '.breadcrumb-fixed'			- Fixed Breadcrumb

// Footer options
1. '.footer-fixed'					- Fixed footer

-->

<body class="app header-fixed sidebar-fixed aside-menu-fixed aside-menu-hidden">
  <header class="app-header navbar">
    <button class="navbar-toggler mobile-sidebar-toggler d-lg-none" type="button">
      <span class="navbar-toggler-icon"></span>
    </button>
    <a class="navbar-brand" href="#"></a>
    <button class="navbar-toggler sidebar-toggler d-md-down-none" type="button">
      <span class="navbar-toggler-icon"></span>
    </button>
    <ul class="nav navbar-nav d-md-down-none mr-auto">

      <li class="nav-item px-3">
        <a class="nav-link" href="ledger?action=topicsPub24Hours">Dashboard</a>
      </li>
      <li class="nav-item px-3">
        <a class="nav-link" href="site?action=topics">Sites</a>
      </li>
      <li class="nav-item px-3">
        <a class="nav-link" href="pub?action=edit">Settings</a>
      </li>
    </ul>
    <ul class="nav navbar-nav ml-auto">
      <li class="nav-item dropdown d-md-down-none">
        <a class="nav-link" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
          <i class="icon-bell"></i><span class="badge badge-pill badge-danger">1</span>
        </a>
        <div class="dropdown-menu dropdown-menu-right dropdown-menu-lg">
          <div class="dropdown-header text-center">
            <strong>You have 1 notification</strong>
          </div>
          <div class="alert alert-default alert-dismissible fade show" role="alert">
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
		    New insurance quote
            <!-- a href="#" class="dropdown-item">
              <i class="icon-chart text-success"></i> New insurance quote
            </a -->
          </div>
        </div>
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link nav-link" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
          <img src="/img/O.png" class="img-avatar" alt="avatar">
        </a>
        <div class="dropdown-menu dropdown-menu-right">
          <div class="dropdown-header text-center">
            <strong>Account</strong>
          </div>
          <a class="dropdown-item" href="#"><i class="fa fa-bell-o"></i> Updates<span class="badge badge-info">42</span></a>
          <a class="dropdown-item" href="#"><i class="fa fa-envelope-o"></i> Messages<span class="badge badge-success">42</span></a>
          <a class="dropdown-item" href="#"><i class="fa fa-tasks"></i> Tasks<span class="badge badge-danger">42</span></a>
          <a class="dropdown-item" href="#"><i class="fa fa-comments"></i> Comments<span class="badge badge-warning">42</span></a>
          <div class="dropdown-header text-center">
            <strong>Settings</strong>
          </div>
          <a class="dropdown-item" href="#"><i class="fa fa-user"></i> Profile</a>
          <a class="dropdown-item" href="#"><i class="fa fa-wrench"></i> Settings</a>
          <a class="dropdown-item" href="#"><i class="fa fa-usd"></i> Payments<span class="badge badge-dark">42</span></a>
          <a class="dropdown-item" href="#"><i class="fa fa-file"></i> Projects<span class="badge badge-primary">42</span></a>
          <div class="divider"></div>
          <a class="dropdown-item" href="#"><i class="fa fa-shield"></i> Lock Account</a>
          <a class="dropdown-item" href="#"><i class="fa fa-lock"></i> Logout</a>
        </div>
      </li>
      <button class="navbar-toggler aside-menu-toggler" type="button">
        <span class="navbar-toggler-icon"></span>
      </button>

    </ul>
  </header>
  <div class="app-body">
    <div class="sidebar">
      <nav class="sidebar-nav">
        <ul class="nav">
          <li class="nav-item">
            <a class="nav-link" href="ledger?action=topicsPub24Hours"><i class="icon-speedometer"></i> Dashboard </a>
          </li>

          <li class="nav-title">
            Publisher
          </li>
          <li class="nav-item">
            <a href="site?action=topics" class="nav-link"><i class="icon-calculator"></i> Apps and Sites</a>
          </li>
          {{ if and ( or (or (eq .Other.Component `slot`) (eq .Other.Component `chac`)) (eq .Other.Component `ac`)) .ARGS.site_name }}<li class="nav-item nav-dropdown">
            <a class="nav-link nav-dropdown-toggle" href="#"><i class="icon-wallet"></i> {{index .ARGS.site_name 0}}</a>
            <ul class="nav-dropdown-items">
              <li class="nav-item">
                <a class="nav-link" href="slot?action=topics&site_id={{index .ARGS.site_id 0}}&site_md5={{index .ARGS.site_md5 0}}&site_name={{index .ARGS.site_name 0 | urlquery }}"><i class="icon-basket"></i> Slots</a>
              </li>
              <li class="nav-item">
                <a class="nav-link" href="ac?action=topics&site_id={{index .ARGS.site_id 0}}&site_md5={{index .ARGS.site_md5 0}}&site_name={{index .ARGS.site_name 0 | urlquery }}&entitytype_id=31"><i class="icon-basket"></i> Access Control</a>
              </li>
              <li class="nav-item">
                <a class="nav-link" href="chac?action=topics&site_id={{index .ARGS.site_id 0}}&site_md5={{index .ARGS.site_md5 0}}&site_name={{index .ARGS.site_name 0 | urlquery }}&entitytype_id=31"><i class="icon-basket"></i> Channels</a>
              </li>
            </ul>
          </li>{{end}}
          <li class="nav-item">
            <a class="nav-link" href="ac?action=topics&entitytype_id=3"><i class="icon-speedometer"></i> Access Control</a>
          </li>
          <li class="nav-item nav-dropdown">
            <a class="nav-link nav-dropdown-toggle" href="#"><i class="icon-calendar"></i> Financial Report</a>
            <ul class="nav-dropdown-items">
              <li class="nav-item">
                <a href="document?action=graduate" class="nav-link"><i class="icon-graduation"></i> Graduate</a>
              </li>
              <li class="nav-item">
                <a href="document?action=w2" class="nav-link"><i class="icon-film"></i> W2's</a>
              </li>
             </ul>
          </li>
          <li class="nav-title">
            Service
          </li>
          <li class="nav-item">
            <a href="tt?action=suppert" class="nav-link"><i class="icon-support"></i> Support</a>
          </li>
        </ul>
      </nav>
      <button class="sidebar-minimizer brand-minimizer" type="button"></button>
    </div>
    <!-- Main content -->
    <main class="main">
{{end}}
