{{define "header"}}
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="商户广告系统- PzAdx">
  <meta name="keyword" content="商户广告系统">
  <title>派兹商户系统 - 为每个广告位谋求最大收益</title>

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

<style>
html, body {
  font-family: "SimSun","宋体";
}
h1, h2, h3, h4, h5, h6, button {
  font-family: "Microsoft YaHei","微软雅黑","SimHei","黑体";
}
.nav {
  font-family: "Microsoft YaHei","微软雅黑","SimHei","黑体";
}
</style>
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
		派兹媒体商: <em>{{index .ARGS.p_email 0}}</em>
      </li>
	<!--
      <li class="nav-item px-3">
        <a class="nav-link" href="ledger?action=topicsPub24Hours">Dashboard</a>
      </li>
      <li class="nav-item px-3">
        <a class="nav-link" href="site?action=topics">Sites</a>
      </li>
      <li class="nav-item px-3">
        <a class="nav-link" href="pub?action=edit">Settings</a>
      </li>
	 -->
    </ul>
    <ul class="nav navbar-nav ml-auto">
      <li class="nav-item dropdown d-md-down-none">
        <i class="icon-bell"></i>
        <!--
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
            <a href="#" class="dropdown-item">
              <i class="icon-chart text-success"></i> New insurance quote
            </a>
          </div>
        </div>
        -->
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link nav-link" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
          <img src="/img/O.png" class="img-avatar" alt="avatar">
        </a>
        <div class="dropdown-menu dropdown-menu-right">
          <div class="dropdown-header text-center">
            <strong>账号</strong>
          </div>
          <a class="dropdown-item" href="pub?action=edit"><i class="fa fa-user"></i> 基本设置</a>
          <a class="dropdown-item" href="pub?action=editpass"><i class="fa fa-wrench"></i> 重置密码</a>
          <a class="dropdown-item" href="logout"><i class="fa fa-lock"></i> 登出</a>
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
            <a class="nav-link" href="ledger?action=topicsPub24Hours"><i class="icon-speedometer"></i> 业绩总结</a>
          </li>

          <li class="nav-title">
            媒体商
          </li>
          <li class="nav-item">
            <a href="ac?action=topics&entitytype_id=3" class="nav-link"><i class="icon-shield"></i> 黑白名单</a>
          </li>
          <li class="nav-item">
            <a href="site?action=topics" class="nav-link"><i class="icon-screen-smartphone"></i> 移动应用或网站</a>
          </li>
          {{ if and ( or (or (or (eq .Other.Component `site`) (eq .Other.Component `slot`)) (eq .Other.Component `chac`)) (eq .Other.Component `ac`)) .ARGS.site_name }} {{$attach := print "site_id=" (index .ARGS.site_id 0) "&site_md5=" (index .ARGS.site_md5 0) "&site_name=" (index .ARGS.site_name 0 | urlquery)}}<li class="nav-title">
            {{index .ARGS.site_name 0}}
          </li>
          <li class="nav-item">
            <a class="nav-link" href="site?action=edit&site_id={{index .ARGS.site_id 0}}&site_md5={{index .ARGS.site_md5 0}}&site_name={{index .ARGS.site_name 0 | urlquery}}"><i class="icon-magic-wand"></i> 编辑</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="slot?action=topics&{{$attach}}"><i class="icon-grid"></i> 所属广告位</a>
          </li>

          {{ if and .ARGS.slot_name .ARGS.slot_md5 }} {{$small := print "slot_id=" (index .ARGS.slot_id 0) "&slot_md5=" (index .ARGS.slot_md5 0) "&slot_name=" (index .ARGS.slot_name 0 | urlquery)}}<li class="nav-item nav-dropdown">
          <li class="nav-item">
            <a class="nav-link" href="slot?action=edit&{{$small}}&{{$attach}}"> <i class="icon-arrow-right"></i> {{index .ARGS.slot_name 0}}</a>
          </li>{{end}} 

          <li class="nav-item">
            <a class="nav-link" href="ac?action=topics&entitytype_id=31&{{$attach}}"><i class="icon-shield"></i> 网站黑白名单</a>
          </li>{{end}}
          <li class="nav-title">
            报表
          </li>
          <li class="nav-item">
             <a href="ledge?action=payment" class="nav-link"><i class="icon-chart"></i> 收入</a>
          </li>
        </ul>
      </nav>
      <button class="sidebar-minimizer brand-minimizer" type="button"></button>
    </div>
    <!-- Main content -->
    <main class="main">
{{end}}
