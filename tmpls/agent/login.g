<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="/favicon.ico">

    <title>审核单位登陆</title>

    <!-- Bootstrap core CSS -->
    <link href="/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="/dashboard.css" rel="stylesheet">
  </head>

  <body>

	<form role="form" METHOD="POST" ACTION="/goto/agent/e/{{ .LoginName }}">
	<INPUT TYPE="HIDDEN" NAME="{{ .GoURIName }}" VALUE="{{ .GoURI }}">
<div class="container-fluid">
	<h2>审核登陆</h2>
	<div class="row">
		<div class="col alert alert-success">
			{{ .Errorstr }}
		</div>
	</div>
	<div class="row">
		<div class="col-2 form-group">
			<label>用户名:</lable>
		</div>
		<div class="col-10 form-group">
			<input class="form-control" placeholder="Login Name" name="{{.Login}}" autofocus>
		</div>
	</div>
	<div class="row">
		<div class="col-2 form-group">
			<label>密码:</lable>
		</div>
		<div class="col-10 form-group">
			<input class="form-control" placeholder="Password" name="{{ .Password }}" type="password" value="">
		</div>

	</div>
	<div class="row">
		<div class="col alert alert-success">
			<button type="submit" class="btn btn-lg btn-success btn-block">登入</button>
		</div>
    </div>
</div>
	</form>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
    <script>window.jQuery || document.write('<script src="/assets/js/vendor/jquery-slim.min.js"><\/script>')</script>
    <script src="/assets/js/vendor/popper.min.js"></script>
    <script src="/dist/js/bootstrap.min.js"></script>

  </body>
</html>
