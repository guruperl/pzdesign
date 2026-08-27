{{ define "header" }}
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="W8M Advertiser, Agency, and Publisher Account Services">
  <meta name="theme-color" content="#0b1f33">

  <title>W8M Account Services</title>

  <link href="/1.0.8/vendors/css/font-awesome.min.css" rel="stylesheet">
  <link href="/1.0.8/vendors/css/simple-line-icons.min.css" rel="stylesheet">
  <link href="/1.0.8/css/style.css" rel="stylesheet">
  <link href="/css/w8m-account.css?v=20260822-1" rel="stylesheet">
</head>

<body class="w8m-public-account {{if eq .Other.Component `pub`}}theme-publisher{{else}}theme-advertiser{{end}}">
  <header class="account-topbar">
    <div class="container">
      <a class="account-brand" href="/">W8M <small>Advertising Platform</small></a>
      <nav class="account-topnav" aria-label="Account Page Navigation">
        <a href="/manuals/advertiser.en.html">Advertiser Manual</a>
        <a href="/manuals/publisher.en.html">Publisher Integration Manual</a>
        <a class="lang-toggle" href="#" data-lang-toggle="zh" title="中文">中文</a>
        <a href="/">Back to Home</a>
      </nav>
    </div>
  </header>
  <main class="account-stage">
    <div class="container">
{{end}}
