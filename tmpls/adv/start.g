{{ define "header" }}
<!DOCTYPE html>
<html lang="zh-CN">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>W8M 广告主工作台</title>

    <!-- Bootstrap Core CSS -->
    <link href="/sb2/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- MetisMenu CSS -->
    <link href="/sb2/vendor/metisMenu/metisMenu.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="/sb2/dist/css/sb-admin-2.css" rel="stylesheet">
    <link href="/css/w8m-workspace.css?v=20260802-1" rel="stylesheet">

    <!-- Morris Charts CSS -->
    <!-- Custom Fonts -->
    <link href="/sb2/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

</head>
<body class="w8m-workspace theme-advertiser">

    <div id="wrapper">

        <!-- Navigation -->
        <nav class="navbar navbar-default navbar-static-top" role="navigation" style="margin-bottom: 0">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <span class="navbar-brand">W8M 广告主工作台</span>
            </div>
            <!-- /.navbar-header -->

            <ul class="nav navbar-top-links navbar-right">
                <!-- /.dropdown -->
                <li class="text-info">
                    {{index .ARGS.a_company 0}}（{{index .ARGS.a_email 0}}）
                </li>
                <li class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <i class="fa fa-user fa-fw"></i> <i class="fa fa-caret-down"></i>
                    </a>
                    <ul class="dropdown-menu dropdown-user">
                        <li><a href="adv?action=edit"><i class="fa fa-user fa-fw"></i> 个人中心</a>
                        </li>
                        <li><a href="adv?action=startpass"><i class="fa fa-gear fa-fw"></i> 修改密码</a>
                        </li>
                        <li><a href="security?action=dashboard"><i class="fa fa-shield fa-fw"></i> 账户安全</a></li>
                        </li>
                        <li class="divider"></li>
                        <li><form method="post" action="logout"><button type="submit" class="btn btn-link"><i class="fa fa-sign-out fa-fw"></i> 退出</button></form></li>
                    </ul>
                    <!-- /.dropdown-user -->
                </li>
                <!-- /.dropdown -->
            </ul>
            <!-- /.navbar-top-links -->

            <div class="navbar-default sidebar" role="navigation">
                <div class="sidebar-nav navbar-collapse">
                    <ul class="nav" id="side-menu">
                        <li>
                            <a href="ledger?action=topicsAdv24Hours"><i class="fa fa-dashboard fa-fw"></i> 业绩概况</a>
                            {{if .Other.ActionReportingEnabled}}<a href="ledger?action=topicsAdvActions"><i class="fa fa-check-square-o fa-fw"></i> 转化与归因</a>{{end}}
                            {{if .Other.MarketplaceReportingEnabled}}<a href="ledger?action=topicsMarketplace"><i class="fa fa-area-chart fa-fw"></i> 投放分析</a>{{end}}
                        </li>
                        <li>
                            <a href="campaign?action=topics"><i class="fa fa-bar-chart-o fa-fw"></i> 广告活动</a>
                        </li>
                        <li>
                            <a href="bidder?action=topics"><i class="fa fa-exchange fa-fw"></i> 竞价端点</a>
                        </li>
                        <li>
                            <a href="apicredential?action=topics"><i class="fa fa-key fa-fw"></i> 管理 API 凭证</a>
                        </li>
                        <li>
                            {{if .Other.HostedPaymentEnabled}}<a href="hostedpayment?action=topics"><i class="fa fa-credit-card fa-fw"></i> 广告账户资金</a>{{end}}
                        </li>
                        <li>
                            <a href="ledger?action=topicsMid24Hours"><i class="fa fa-line-chart fa-fw"></i> 竞价报告</a>
                        </li>
                        {{ if and (or (or (or (or (or (or (eq .Other.Component `ac`)) (eq .Other.Component `campaign`)) (eq .Other.Component `item`)) (eq .Other.Component `balance`)) (eq .Other.Component `targetname`)) (eq .Other.Component `chac`)) .ARGS.campaign_md5}}
                        <li>
                            <ul class="nav nav-second-level nav-compact-sm">
                                <li>
                                    <span class="nav-link">{{index .ARGS.campaign_name 0}}</span>
                                </li>
                                <li>
                                    <a href="item?action=topics&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}">广告组</a>
                                </li>
                                <!-- li>
                                    <a href="targetname?action=topics&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}">人群定向</a>
                                </li -->
                            </ul>
                            <!-- /.nav-second-level -->
                        </li>
                        {{end}}
                        <li>
                            <a href="ac?action=topics&entitytype_id=4"><i class="fa fa-table fa-fw"></i> 网站黑白名单</a>
                        </li>
                        <li>
                            <a href="attrname?action=topics"><i class="fa fa-edit fa-fw"></i> 标签管理</a>
                        </li>
                        <li>
                            <a href="ledger?action=topicsAdv24Hours"><i class="fa fa-edit fa-fw"></i> 财务报告</a>
                        </li>

                    </ul>
                </div>
                <!-- /.sidebar-collapse -->
            </div>
            <!-- /.navbar-static-side -->
        </nav>

        <div id="page-wrapper">

{{end}}
