<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>广告主工作台提示｜W8M</title>
  <link href="/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="/css/w8m-account.css?v=20260801-3" rel="stylesheet">
</head>
<body class="w8m-public-account theme-advertiser">
  <main class="account-stage"><div class="container"><div class="account-card account-card-compact theme-advertiser">
    <aside class="account-context"><div class="account-context-copy"><p class="account-eyebrow">广告主工作台</p>{{if eq .Code 503}}<h2>功能暂未开放</h2><p>当前环境尚未完成此功能所需的配置或数据迁移。</p>{{else}}<h2>无法完成当前操作</h2><p>请检查提交内容或重新登录后再试。</p>{{end}}</div></aside>
    <section class="account-form-panel"><div class="account-form-heading"><span class="account-kicker">处理结果</span>{{if eq .Code 503}}<h1>此功能尚未启用</h1><p>现有广告投放功能不受影响。功能启用后，此页面将自动开放。</p>{{else}}<h1>当前请求未能完成</h1><p>如果问题持续，请联系技术支持并提供下方错误编号。</p>{{end}}</div><div class="account-actions"><a class="account-action" href="/goto/adv/g/campaign?action=topics">返回广告主工作台</a><a class="account-action-secondary" href="mailto:support@w8m.com">联系技术支持</a></div><p class="account-support-reference">错误编号：{{.Code}}</p></section>
  </div></div></main>
</body>
</html>
