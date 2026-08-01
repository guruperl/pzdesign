<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="W8M 代理商后台登录">
  <meta name="theme-color" content="#0b1f33">
  <title>代理商后台登录｜W8M</title>
  <link href="/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
  <link href="/css/w8m-account.css?v=20260801-3" rel="stylesheet">
</head>

<body class="w8m-public-account theme-internal">
  <header class="account-topbar">
    <div class="container">
      <a class="account-brand" href="/">W8M <small>代理商后台</small></a>
      <nav class="account-topnav" aria-label="代理登录页导航">
        <a href="mailto:support@w8m.com">技术支持</a>
        <a href="/">返回首页</a>
      </nav>
    </div>
  </header>

  <main class="account-stage">
    <div class="container">
      <div class="account-card account-card-compact theme-internal">
        <aside class="account-context">
          <div class="account-context-copy">
            <span class="account-role-mark"><i class="fa fa-check-square-o" aria-hidden="true"></i></span>
            <p class="account-eyebrow">授权账户</p>
            <h2>代理审核与查看</h2>
            <p>此入口用于受托查看广告主、广告活动和广告组，并完成被授权的审核工作。</p>
          </div>
        </aside>

        <section class="account-form-panel">
          <div class="account-form-heading">
            <span class="account-kicker">账户登录</span>
            <h1>代理商后台登录</h1>
            <p>请输入代理账户用户名和密码。</p>
          </div>
          {{if .Errorstr}}<div class="account-alert"><i class="fa fa-info-circle" aria-hidden="true"></i>
            {{if or (eq .Errorstr "Sign In to your account") (eq .Errorstr "Login required.")}}请输入用户名和密码。
            {{else if eq .Errorstr "Login is expired."}}登录状态已失效，请重新登录。
            {{else if eq .Errorstr "Too many failed logins."}}登录尝试次数过多，请稍后再试。
            {{else if or (eq .Errorstr "Login incorrect. Please try again.") (eq .Errorstr "Login failed. Please try again.")}}用户名或密码不正确，请重新输入。
            {{else if eq .Errorstr "Please make sure your browser supports cookie."}}登录需要启用 Cookie，请检查浏览器设置。
            {{else}}暂时无法登录，请检查登录信息后重试。
            {{end}}
          </div>{{end}}
          <form method="post" action="/goto/agent/g/{{ .LoginName }}">
            <input type="hidden" name="{{ .GoURIName }}" value="{{ .GoURI }}">
            <div class="account-field">
              <label for="agent-login-name">代理账户用户名</label>
              <div class="account-control"><i class="fa fa-user-o" aria-hidden="true"></i><input id="agent-login-name" class="form-control" name="{{.Login}}" type="text" placeholder="输入代理账户用户名" autocomplete="username" autofocus required></div>
            </div>
            <div class="account-field">
              <label for="agent-login-password">密码</label>
              <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input id="agent-login-password" class="form-control" name="{{.Password}}" type="password" placeholder="输入密码" autocomplete="current-password" required></div>
            </div>
            <button type="submit" class="account-submit">登录代理商后台</button>
          </form>
        </section>
      </div>
    </div>
  </main>

  <footer class="account-footer"><div class="container"><p>&copy; 2026 W8M 网络有限公司</p><a href="mailto:support@w8m.com">support@w8m.com</a></div></footer>
</body>
</html>
