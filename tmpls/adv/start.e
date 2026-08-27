{{ define "header" }}
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Advertiser Management - W8M</title>

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
                <span class="navbar-brand">Advertiser at W8M</span>
            </div>
            <!-- /.navbar-header -->

            <ul class="nav navbar-top-links navbar-right">
                <!-- /.dropdown -->
<li class="text-info">{{index .ARGS.a_email 0}} of {{index .ARGS.a_company 0}}</li>
                <li class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <i class="fa fa-user fa-fw"></i> <i class="fa fa-caret-down"></i>
                    </a>
                    <ul class="dropdown-menu dropdown-user">
                        <li><a href="adv?action=edit"><i class="fa fa-user fa-fw"></i> User Profile</a>
                        </li>
                        <li><a href="adv?action=startpass"><i class="fa fa-gear fa-fw"></i> Change Password</a>
                        </li>
                        <li><a href="security?action=dashboard"><i class="fa fa-shield fa-fw"></i> Account Security</a></li>
                        </li>
                        <li class="divider"></li>
                        <li><form method="post" action="logout"><button type="submit" class="btn btn-link"><i class="fa fa-sign-out fa-fw"></i> Logout</button></form></li>
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
                            <a href="adv?action=dashboard"><i class="fa fa-dashboard fa-fw"></i> Dashboard</a>
                        </li>
                        <li>
                            <a href="apicredential?action=topics"><i class="fa fa-key fa-fw"></i> Management API credentials</a>
                        </li>
                        <li>
                            {{if .Other.HostedPaymentEnabled}}<a href="hostedpayment?action=topics"><i class="fa fa-credit-card fa-fw"></i> Advertiser funding</a>{{end}}
                        </li>
                        <li>
                            <a href="#"><i class="fa fa-bar-chart-o fa-fw"></i> Campaigns<span class="fa arrow"></span></a>
                            <ul class="nav nav-second-level">
                                <li>
                                    <a href="campaign?action=topics">List Campaigns</a>
                                </li>
                                {{ if or (or (or (or (or (eq .Other.Component `campaign`) (eq .Other.Component `item`)) (eq .Other.Component `balance`)) (eq .Other.Component `targetname`)) (eq .Other.Component `chac`)) (eq .Other.Component `ac`) }}{{if .ARGS.campaign_md5}}<li>
                                    <a href="campaign?action=edit&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}">{{index .ARGS.campaign_name 0}}</a>
                                </li>
                                <li>
                                    <a href="#">CLICK TO MANAGE <span class="fa arrow"></span></a>
                                    <ul class="nav nav-third-level">
                                        <li>
                                            <a href="item?action=topics&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}">Items</a>
                                        </li>
                                        <li>
                                            <a href="item?action=startnew&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}">Create Item</a>
                                        </li>
                                        <li>
                                            <a href="balance?action=topics&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}&entitytype_id=41">Budgeting</a>
                                        </li>
                                        <li>
                                            <a href="targetname?action=topics&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}">Targeting</a>
                                        </li>
                                        <li>
                                            <a href="chac?action=topics&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}&entitytype_id=41">Channels</a>
                                        </li>
                                        <!-- li>
                                            <a href="ac?action=topics&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}&entitytype_id=41">Access Control</a>
                                        </li -->
                                    </ul>
                                </li>
                                {{end}}{{end}}
                            </ul>
                            <!-- /.nav-second-level -->
                        </li>
                        <li>
                            <a href="ac?action=topics&entitytype_id=4"><i class="fa fa-table fa-fw"></i> Access Control</a>
                        </li>
                        <li>
                            <a href="attrname?action=topics"><i class="fa fa-edit fa-fw"></i> Custom Tags</a>
                        </li>
                        <li>
                <a href="ledger?action=topicsAdv24Hours"><i class="fa fa-edit fa-fw"></i> Financial Reports</a>
                {{if .Other.MarketplaceReportingEnabled}}<a href="ledger?action=topicsMarketplace"><i class="fa fa-area-chart fa-fw"></i> Marketplace analytics</a>{{end}}
                {{if .Other.ActionReportingEnabled}}<a href="ledger?action=topicsAdvActions"><i class="fa fa-check-square-o fa-fw"></i> Actions &amp; Attribution</a>{{end}}
                        </li>
                    </ul>
                </div>
                <!-- /.sidebar-collapse -->
            </div>
            <!-- /.navbar-static-side -->
        </nav>

        <div id="page-wrapper">
{{end}}
