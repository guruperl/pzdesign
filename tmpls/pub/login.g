<!DOCTYPE html>
<html lang="en">
<head>

  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="EIC Membership Login">
  <meta name="author" content="Lukasz Holeczek">
  <meta name="keyword" content="EIC Membership Login">
  <!-- <link rel="shortcut icon" href="assets/ico/favicon.png"> -->

  <title>登入W8M 流量源公司内网</title>

  <!-- Icons -->
  <link href="/1.0.8/vendors/css/font-awesome.min.css" rel="stylesheet">
  <link href="/1.0.8/vendors/css/simple-line-icons.min.css" rel="stylesheet">

  <!-- Main styles for this application -->
  <link href="/1.0.8/css/style.css" rel="stylesheet">

  <!-- Styles required by this views -->

</head>

<body class="app flex-row align-items-center">
  <div class="container">
<FORM METHOD="POST" ACTION="{{ .LoginName }}">
<INPUT TYPE="HIDDEN" NAME="{{ .GoURIName }}" VALUE="{{ .GoURI }}" />
    <div class="row justify-content-center">
      <div class="col-md-8">
        <div class="card-group">
          <div class="card p-4">
            <div class="card-body">
              <h1>流量源公司登入</h1>
              <p class="text-muted">{{.Errorstr}}</p>
              <div class="input-group mb-3">
                <div class="input-group-prepend">
                  <span class="input-group-text"><i class="icon-user"></i></span>
                </div>
                <input type="text" class="form-control" name="{{ .Login }}" placeholder="电子邮箱">
              </div>
              <div class="input-group mb-4">
                <div class="input-group-prepend">
                  <span class="input-group-text"><i class="icon-lock"></i></span>
                </div>
                <input type="password" class="form-control" NAME="{{ .Password }}" placeholder="密码">
              </div>
              <div class="row">
                <div class="col-6">
                  <button type="submit" class="btn btn-primary px-4">登入</button>
                </div>
                <div class="col-6 text-right">
                  <a href="/goto/web/g/pub?action=startretrieve" class="btn btn-link px-0">遗忘密码?</a>
                </div>
              </div>
            </div>
          </div>
          <div class="card text-white bg-primary py-5 d-md-down-none" style="width:44%">
            <div class="card-body text-center">
              <div>
                <h2>注册</h2>
                <p>让优质流量源获得高CPM，这是我们保证！平台自动为流量源的广告位抓取最高价位广告。流量源端可以通过对流量来源，知名度，内容频道等的改进，提高流量质量，而不断提升CPM。</p>
                <a href="/goto/web/g/pub?action=startnew" class="btn btn-primary active mt-3">现在注册!</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    </FORM>
  </div>

  <!-- Bootstrap and necessary plugins -->
  <script src="/1.0.8/vendors/js/jquery.min.js"></script>
  <script src="/1.0.8/vendors/js/popper.min.js"></script>
  <script src="/1.0.8/vendors/js/bootstrap.min.js"></script>

</body>
</html>
