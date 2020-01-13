{{ define "header" }}
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>派兹SSP广告主管理系统</title>

    <!-- Bootstrap Core CSS -->
    <link href="/sb2/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- MetisMenu CSS -->
    <link href="/sb2/vendor/metisMenu/metisMenu.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="/sb2/dist/css/sb-admin-2.css" rel="stylesheet">

    <!-- Morris Charts CSS -->
    <!-- link href="/sb2/vendor/morrisjs/morris.css" rel="stylesheet" -->

    <!-- Custom Fonts -->
    <link href="/sb2/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
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
.nav-compact {
	font-size: small
}
.nav-compact-sm {
	font-size: smaller
}
</style>

</head>

<body>

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
                <a class="navbar-brand" href="/index.html">派兹广告主管理系统</a>
            </div>
            <!-- /.navbar-header -->

            <ul class="nav navbar-top-links navbar-right">
                <!-- /.dropdown -->
				<li class="text-info">
					{{index .ARGS.a_email 0}} of {{index .ARGS.a_company 0}}
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
                        <li><a href="payment?action=topics"><i class="fa fa-money fa-fw"></i> 余额管理</a>
                        </li>
                        <li class="divider"></li>
                        <li><a href="logout"><i class="fa fa-sign-out fa-fw"></i> 退出</a>
                        </li>
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
                        </li>
                        <li>
                            <a href="campaign?action=topics"><i class="fa fa-bar-chart-o fa-fw"></i> 广告活动</a>
						</li>
{{ if and (or (or (or (or (or (or (eq .Other.Component `ac`)) (eq .Other.Component `campaign`)) (eq .Other.Component `item`)) (eq .Other.Component `balance`)) (eq .Other.Component `targetname`)) (eq .Other.Component `chac`)) .ARGS.campaign_md5}}
						<li>
                            <ul class="nav nav-second-level nav-compact-sm">
								<li>
                                 	<a href="javascript:void(0);">{{index .ARGS.campaign_name 0}}</a>
                                </li>
                                <li>
                                 	<a href="item?action=topics&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}">所有创意</a>
                                </li>
                                <li>
                                   	<a href="targetname?action=topics&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery }}">人群定向</a>
                                </li>
                            </ul>
                            <!-- /.nav-second-level -->
                        </li>
						{{end}}
                        <li>
                            <a href="ac?action=topics&entitytype_id=4"><i class="fa fa-table fa-fw"></i> 网站黑白名单</a>
                        </li>
                        <li>
                            <a href="attrname?action=topics"><i class="fa fa-edit fa-fw"></i> 自定义标签</a>
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
