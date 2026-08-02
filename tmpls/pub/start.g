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
  <link href="/css/w8m-workspace.css?v=20260802-1" rel="stylesheet">
</head>

<body class="app header-fixed sidebar-fixed aside-menu-fixed aside-menu-hidden w8m-workspace theme-publisher">
  <header class="app-header navbar">
    <button class="navbar-toggler mobile-sidebar-toggler d-lg-none" type="button">
      <span class="navbar-toggler-icon"></span>
    </button>
    <span class="navbar-brand">W8M <small>流量方工作台</small></span>
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
        <a class="nav-link workspace-account-menu" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
          <span>账户</span><i class="fa fa-angle-down" aria-hidden="true"></i>
        </a>
        <div class="dropdown-menu dropdown-menu-right">
          <div class="dropdown-header text-center">
            <strong>账户</strong>
          </div>
          <a class="dropdown-item" href="pub?action=edit"><i class="fa fa-user"></i> 基本设置</a>
          <a class="dropdown-item" href="pub?action=editpass"><i class="fa fa-wrench"></i> 重置密码</a>
          <a class="dropdown-item" href="security?action=dashboard"><i class="fa fa-shield"></i> 账户安全</a>
          <form method="post" action="logout"><button class="dropdown-item" type="submit"><i class="fa fa-lock"></i> 退出登录</button></form>
        </div>
      </li>
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
          <li class="nav-item">
             {{if .Other.MarketplaceReportingEnabled}}<a href="ledger?action=topicsMarketplace" class="nav-link"><i class="icon-graph"></i> 流量收益分析</a>{{end}}
          </li>
          <li class="nav-item">
             {{if .Other.HostedPaymentEnabled}}<a href="hostedpayment?action=topics" class="nav-link {{if eq $c `hostedpayment`}}active{{end}}"><i class="icon-wallet"></i> 收益结算账户</a>{{end}}
          </li>
        </ul>
      </nav>
      <button class="sidebar-minimizer brand-minimizer" type="button"></button>
    </div>
    <!-- Main content -->
    <main class="main">
{{end}}
