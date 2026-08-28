<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="W8M 请求处理提示">
  <meta name="theme-color" content="#0b1f33">
  <title>请求处理提示｜W8M</title>
  <link href="/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
  <link href="/css/w8m-account.css?v=20260828-1" rel="stylesheet">
</head>

<body class="w8m-public-account theme-internal">
  <header class="account-topbar">
    <div class="container">
      <a class="account-brand" href="/">W8M <small>广告平台</small></a>
      <nav class="account-topnav" aria-label="错误页导航">
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
            <span class="account-role-mark"><i class="fa fa-info" aria-hidden="true"></i></span>
            <p class="account-eyebrow">请求处理</p>
            <h2>无法完成当前操作</h2>
            <p>请根据右侧说明检查请求，或返回首页选择正确的账户入口。</p>
          </div>
        </aside>

        <section class="account-form-panel">
          <span class="account-status-icon"><i class="fa fa-exclamation" aria-hidden="true"></i></span>
          <div class="account-form-heading">
            <span class="account-kicker">处理结果</span>
            {{if eq .Code 404}}
              <h1>页面不存在或链接已失效</h1>
              <p>请检查页面地址。如果这是邮件中的链接，请重新发起账户验证或密码重置。</p>
            {{else if eq .Code 405}}
              <h1>当前操作方式不受支持</h1>
              <p>请返回上一页，并使用页面提供的按钮或表单重新操作。</p>
            {{else if eq .Code 429}}
              <h1>操作过于频繁</h1>
              <p>请稍后再试，不要连续重复提交相同请求。</p>
            {{else if or (eq .Code 401) (eq .Code 403)}}
              <h1>当前请求没有访问权限</h1>
              <p>请确认使用了正确的账户入口和有效链接，然后重新登录或再次操作。</p>
            {{else if or (eq .Code 400) (eq .Code 1037) (eq .Code 1040)}}
              <h1>提交的信息不完整或格式不正确</h1>
              <p>请返回上一页，检查必填项和输入格式后重新提交。</p>
            {{else if eq .Code 3102}}
              <h1>提交的信息无法验证</h1>
              <p>请检查两次输入的密码是否一致，或重新打开最新邮件中的验证链接。</p>
            {{else if eq .Code 3104}}
              <h1>该账户信息已被使用</h1>
              <p>请使用其他账户信息注册，或返回对应的登录页面。</p>
            {{else}}
              <h1>暂时无法完成请求</h1>
              <p>请稍后重试。如果问题持续，请联系技术支持并提供下方错误编号。</p>
            {{end}}
          </div>
          <div class="account-actions">
            <a class="account-action" href="/">返回首页</a>
            <a class="account-action-secondary" href="mailto:support@w8m.com">联系技术支持</a>
          </div>
          <p class="account-support-reference">错误编号：{{.Code}}</p>
        </section>
      </div>
    </div>
  </main>

  <footer class="account-footer"><div class="container"><p>&copy; 2026 W8M 网络有限公司</p><a href="mailto:support@w8m.com">support@w8m.com</a></div></footer>
</body>
</html>
