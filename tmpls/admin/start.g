{{ define "header" }}
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="/admin/favicon.ico">

    <title>W8M 后台管理系统</title>

    <!-- Bootstrap core CSS -->
    <link href="/admin/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="/admin/dashboard.css?v=20260828-1" rel="stylesheet">
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

  <body>
    <nav class="navbar navbar-dark sticky-top bg-dark flex-md-nowrap p-0">
      <a class="navbar-brand col-sm-3 col-md-2 mr-0" href="#">W8M 系统管理员</a>
    <div class="navbar-brand">
&nbsp; 欢迎 <em>{{index .ARGS.admin_login 0}}</em>，管理员 ID：<em>{{index .ARGS.admin_id 0}}</em> &nbsp;
	</div>
      <ul class="navbar-nav px-3">
        <li class="nav-item text-nowrap"><a class="nav-link" href="security?action=dashboard">账户安全</a></li>
        <li class="nav-item text-nowrap"><form method="post" action="logout"><button class="btn btn-link nav-link" type="submit">退出</button></form></li>
      </ul>
    </nav>

    <div class="container-fluid">
      <div class="row">
        <nav class="col-md-2 d-none d-md-block bg-light sidebar">
          <div class="sidebar-sticky">
            <ul class="nav flex-column">
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `agent` }} active{{end}}" href="agent?action=topics">
                  代理商 {{ if eq .Other.Component "agent" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `adv` }} active{{end}}" href="adv?action=topics">
                  广告主 {{ if eq .Other.Component "adv" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `campaign` }} active{{end}}" href="campaign?action=topics">
                  广告活动 {{ if eq .Other.Component "campaign" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `bidder` }} active{{end}}" href="bidder?action=topics">
                  竞价端点 {{ if eq .Other.Component "bidder" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `apicredential` }} active{{end}}" href="apicredential?action=topics">
                  管理 API 凭证
                </a>
              </li>
              {{if .Other.PublisherAuthEnabled}}<li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `publishercredential` }} active{{end}}" href="publishercredential?action=topics">
                  流量方请求凭证
                </a>
              </li>{{end}}
              {{if .Other.HostedPaymentEnabled}}<li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `hostedpayment` }} active{{end}}" href="hostedpayment?action=topics">
                  托管资金与结算
                </a>
              </li>{{end}}
              <li class="nav-item">
                <a class="nav-link{{ if and (eq .Other.Component `ledger`) (eq .Other.Action `topicsMid24Hours`) }} active{{end}}" href="ledger?action=topicsMid24Hours">
                  外部 DSP / ADX 需求方报表 {{ if and (eq .Other.Component "ledger") (eq .Other.Action "topicsMid24Hours") }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              {{if .Other.MarketplaceReportingEnabled}}<li class="nav-item">
                <a class="nav-link{{ if and (eq .Other.Component `ledger`) (eq .Other.Action `topicsMarketplace`) }} active{{end}}" href="ledger?action=topicsMarketplace">
                  市场经营分析
                </a>
              </li>{{end}}
              <li class="nav-item">
                <a class="nav-link{{ if and (eq .Other.Component `ledger`) (eq .Other.Action `topicsExperiments`) }} active{{end}}" href="ledger?action=topicsExperiments">
                  实验状态
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `midroute` }} active{{end}}" href="midroute?action=topics">
                  外部 DSP / ADX 需求方路由 {{ if eq .Other.Component "midroute" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `pub` }} active{{end}}" href="pub?action=topics">
                  流量方账户 {{ if eq .Other.Component "pub" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link{{ if eq .Other.Component `site` }} active{{end}}" href="site?action=topics">
                  网站 / App 流量源 {{ if eq .Other.Component "site" }}<span class="sr-only">(current)</span>{{ end }}
                </a>
              </li>
            </ul>

          </div>
        </nav>

        <main role="main" class="col-md-9 ml-sm-auto col-lg-10 pt-3 px-4">

{{ end }}
