<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="W8M 流量方（发布商）工作台登录">
  <meta name="theme-color" content="#0b1f33">
  <title>流量方登录｜W8M</title>
  <link href="/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
  <link href="/css/w8m-account.css?v=20260801-3" rel="stylesheet">
</head>

<body class="w8m-public-account theme-publisher">
  <header class="account-topbar">
    <div class="container">
      <a class="account-brand" href="/">W8M <small>广告平台</small></a>
      <nav class="account-topnav" aria-label="账户页导航">
        <a href="/manuals/publisher.html">流量方接入手册</a>
        <a href="/goto/web/g/pub?action=startnew">注册账户</a>
        <a href="/">返回首页</a>
      </nav>
    </div>
  </header>

  <main class="account-stage">
    <div class="container">
      <div class="account-card theme-publisher">
        <aside class="account-context">
          <div class="account-context-copy">
            <span class="account-role-mark"><i class="fa fa-globe" aria-hidden="true"></i></span>
            <p class="account-eyebrow">流量方（发布商）后台</p>
            <h2>流量接入管理</h2>
            <p>进入工作台，管理网站、App、广告位、接入代码和流量报表。</p>
            <ul class="account-benefits">
              <li>维护网站、App 和来源主机</li>
              <li>生成网页广告码与 API 样例</li>
              <li>查看填充、展示、点击和收益</li>
            </ul>
          </div>
          <div class="account-context-footer"><a href="/manuals/publisher.html">查看流量方接入手册</a></div>
        </aside>

        <section class="account-form-panel">
          <div class="account-form-heading">
            <span class="account-kicker">账户登录</span>
            <h1>流量方账户登录</h1>
            <p>使用注册邮箱和密码进入流量方工作台。</p>
          </div>

          {{if .Errorstr}}<div class="account-alert"><i class="fa fa-info-circle" aria-hidden="true"></i>
            {{if or (eq .Errorstr "Sign In to your account") (eq .Errorstr "Login required.")}}请输入注册邮箱和密码。
            {{else if eq .Errorstr "Login is expired."}}登录状态已失效，请重新登录。
            {{else if eq .Errorstr "Too many failed logins."}}登录尝试次数过多，请稍后再试。
            {{else if or (eq .Errorstr "Login incorrect. Please try again.") (eq .Errorstr "Login failed. Please try again.")}}邮箱或密码不正确，请重新输入。
            {{else if eq .Errorstr "Please make sure your browser supports cookie."}}登录需要启用 Cookie，请检查浏览器设置。
            {{else}}暂时无法登录，请检查登录信息后重试。
            {{end}}
          </div>{{end}}

          <form method="post" action="{{ .LoginName }}">
            <input type="hidden" name="{{ .GoURIName }}" value="{{ .GoURI }}">
            <div class="account-field">
              <label for="pub-login-email">电子邮箱</label>
              <div class="account-control"><i class="fa fa-envelope-o" aria-hidden="true"></i><input id="pub-login-email" class="form-control" name="{{ .Login }}" type="email" placeholder="name@example.com" autocomplete="username" autofocus required></div>
            </div>
            <div class="account-field">
              <label for="pub-login-password">密码</label>
              <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input id="pub-login-password" class="form-control" name="{{ .Password }}" type="password" placeholder="输入密码" autocomplete="current-password" required></div>
            </div>
            <div class="account-field"><label for="pub-login-totp">身份验证器验证码或恢复代码</label><div class="account-control"><i class="fa fa-shield" aria-hidden="true"></i><input id="pub-login-totp" class="form-control" name="{{.TOTP}}" type="text" placeholder="已启用双重验证时填写" autocomplete="one-time-code"></div></div>
            <button type="submit" class="account-submit">登录流量方工作台</button>
            <div class="account-form-links">
              <a href="/goto/web/g/pub?action=startretrieve">忘记密码？</a>
              <a href="/goto/web/g/pub?action=startnew">创建流量方账户</a>
            </div>
          </form>
        </section>
      </div>
    </div>
  </main>

  <footer class="account-footer"><div class="container"><p>&copy; 2026 W8M 网络有限公司</p><a href="mailto:support@w8m.com">support@w8m.com</a></div></footer>
</body>
</html>
