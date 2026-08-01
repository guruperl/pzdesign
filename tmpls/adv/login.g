<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="W8M 广告主工作台登录">
  <meta name="theme-color" content="#0b1f33">
  <title>广告主登录｜W8M</title>
  <link href="/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
  <link href="/css/w8m-account.css?v=20260801-2" rel="stylesheet">
</head>

<body class="w8m-public-account theme-advertiser">
  <header class="account-topbar">
    <div class="container">
      <a class="account-brand" href="/">W8M <small>广告平台</small></a>
      <nav class="account-topnav" aria-label="账户页导航">
        <a href="/manuals/advertiser.html">广告主手册</a>
        <a href="/goto/web/g/adv?action=startnew">注册账户</a>
        <a href="/">返回首页</a>
      </nav>
    </div>
  </header>

  <main class="account-stage">
    <div class="container">
      <div class="account-card theme-advertiser">
        <aside class="account-context">
          <div class="account-context-copy">
            <span class="account-role-mark"><i class="fa fa-bullseye" aria-hidden="true"></i></span>
            <p class="account-eyebrow">广告主后台</p>
            <h2>广告投放管理</h2>
            <p>进入工作台，管理广告活动、投放项目、素材、定向和效果报表。</p>
            <ul class="account-benefits">
              <li>检查预算、状态和投放周期</li>
              <li>配置素材、频次和多维定向</li>
              <li>查看展示、点击和花费数据</li>
            </ul>
          </div>
          <div class="account-context-footer"><a href="/manuals/advertiser.html">查看广告主使用手册</a></div>
        </aside>

        <section class="account-form-panel">
          <div class="account-form-heading">
            <span class="account-kicker">账户登录</span>
            <h1>广告主账户登录</h1>
            <p>使用注册邮箱和密码进入广告主工作台。</p>
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

          <form method="post" action="/goto/adv/g/{{ .LoginName }}">
            <input type="hidden" name="{{ .GoURIName }}" value="{{ .GoURI }}">
            <div class="account-field">
              <label for="adv-login-email">电子邮箱</label>
              <div class="account-control"><i class="fa fa-envelope-o" aria-hidden="true"></i><input id="adv-login-email" class="form-control" name="{{.Login}}" type="email" placeholder="name@example.com" autocomplete="username" autofocus required></div>
            </div>
            <div class="account-field">
              <label for="adv-login-password">密码</label>
              <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input id="adv-login-password" class="form-control" name="{{.Password}}" type="password" placeholder="输入密码" autocomplete="current-password" required></div>
            </div>
            <button type="submit" class="account-submit">登录广告主工作台</button>
            <div class="account-form-links">
              <a href="/goto/web/g/adv?action=startretrieve">忘记密码？</a>
              <a href="/goto/web/g/adv?action=startnew">创建广告主账户</a>
            </div>
          </form>
        </section>
      </div>
    </div>
  </main>

  <footer class="account-footer"><div class="container"><p>&copy; 2026 W8M 网络有限公司</p><a href="mailto:support@w8m.com">support@w8m.com</a></div></footer>
</body>
</html>
