{{define "header"}}
<!DOCTYPE html> {{$c := .Other.Component}} {{$a := .Other.Action}}
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="W8M 流量方（发布商）工作台">
  <meta name="keyword" content="流量接入,流量方,发布商,广告位">
  <title>W8M 流量方工作台</title>

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
		W8M 流量方账户：<em>{{index .ARGS.p_email 0}}</em>
      </li>
    </ul>
    <ul class="nav navbar-nav ml-auto">
      <li class="nav-item dropdown d-md-down-none">
        <i class="icon-bell"></i>
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link nav-link" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
          <img src="/img/O.png" class="img-avatar" alt="avatar">
        </a>
        <div class="dropdown-menu dropdown-menu-right">
          <div class="dropdown-header text-center">
            <strong>账户</strong>
          </div>
          <a class="dropdown-item" href="pub?action=edit"><i class="fa fa-user"></i> 基本设置</a>
          <a class="dropdown-item" href="pub?action=editpass"><i class="fa fa-wrench"></i> 重置密码</a>
          <a class="dropdown-item" href="logout"><i class="fa fa-lock"></i> 退出登录</a>
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
            <a class="nav-link {{if and (eq $c `pub`) (eq $a `dashboard`) }}active{{end}}" href="pub?action=dashboard"><i class="icon-speedometer"></i> 账户概况</a>
          </li>

          <li class="nav-title">
            流量接入
          </li>
          <li class="nav-item">
            <a href="site?action=topics" class="nav-link {{if and (eq $c `site`) (eq $a `topics`) }}active{{end}}"><i class="icon-screen-smartphone"></i> 网站与 App</a>
          </li>
          <li class="nav-item">
            <a href="ac?action=topics&entitytype_id=3" class="nav-link {{if .ARGS.entitytype_id}}{{if and (and (eq $c `ac`) (eq $a `topics`)) (eq (index .ARGS.entitytype_id 0) `3`) }}active{{end}}{{end}}"><i class="icon-shield"></i> 广告审核</a>
          </li>


          {{ if and ( or (or (or (eq .Other.Component `site`) (eq .Other.Component `slot`)) (eq .Other.Component `chac`)) (eq .Other.Component `ac`)) .ARGS.site_md5 }}<li class="nav-title">
            {{index .ARGS.site_name 0}} <i class="icon-arrow-down mt-4"></i>
          </li>
          <li class="nav-item">
            <a class="nav-link {{if and (eq $c `slot`) (eq $a `topics`) }}active{{end}}" href="slot?action=topics&site_id={{index .ARGS.site_id 0}}&site_md5={{index .ARGS.site_md5 0}}&site_name={{index .ARGS.site_name 0 | urlquery}}"><i class="icon-grid"></i> 所有广告位</a>
          </li>

          {{ if and .ARGS.slot_name .ARGS.slot_md5 }}<li class="nav-title">
            {{index .ARGS.slot_name 0}}
          </li>
          <li class="nav-item">
            <a class="nav-link {{if and (eq $c `slot`) (eq $a `edit`) }}active{{end}}" href="slot?action=edit&slot_id={{index .ARGS.slot_id 0}}&slot_md5={{index .ARGS.slot_md5 0}}&slot_name={{index .ARGS.slot_name 0 | urlquery}}&site_id={{index .ARGS.site_id 0}}&site_md5={{index .ARGS.site_md5 0}}&site_name={{index .ARGS.site_name 0 | urlquery}}"> <i class="icon-arrow-right"></i> 编辑</a>
          </li>{{end}} 
          {{end}}


          <li class="nav-title">
            报表
          </li>
          <li class="nav-item">
             <a href="ledger?action=topicsPub24Hours" class="nav-link"><i class="icon-chart"></i> 收入报表</a>
          </li>
        </ul>
      </nav>
      <button class="sidebar-minimizer brand-minimizer" type="button"></button>
    </div>
    <!-- Main content -->
    <main class="main">
{{end}}
