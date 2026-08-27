<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="/admin/favicon.ico">

    <title>Dashboard Template for Bootstrap</title>

    <!-- Bootstrap core CSS -->
    <link href="/admin/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="/admin/dashboard.css" rel="stylesheet">
  </head>

  <body>

	<form role="form" METHOD="POST" ACTION="/goto/agent/e/{{ .LoginName }}">
	<INPUT TYPE="HIDDEN" NAME="{{ .GoURIName }}" VALUE="{{ .GoURI }}">
<div class="container-fluid">
	<h2>Login</h2>
		<div class="row">
		<div class="col alert alert-success">
			{{if or (eq .Errorstr "Sign In to your account") (eq .Errorstr "Login required.")}}Enter your username and password.
			{{else if eq .Errorstr "Login is expired."}}Your session has expired. Sign in again.
			{{else if eq .Errorstr "Too many failed logins."}}Too many sign-in attempts. Try again later.
			{{else if or (eq .Errorstr "Login incorrect. Please try again.") (eq .Errorstr "Login failed. Please try again.")}}The username or password is incorrect.
			{{else if eq .Errorstr "Please make sure your browser supports cookie."}}Cookies must be enabled to sign in.
			{{else if .Errorstr}}We could not sign you in. Check your information and try again.
			{{end}}
		</div>
	</div>
	<div class="row">
		<div class="col-2 form-group">
			<label>Login:</lable>
		</div>
		<div class="col-10 form-group">
			<input class="form-control" placeholder="Login Name" name="{{.Login}}" autofocus>
		</div>
	</div>
	<div class="row">
		<div class="col-2 form-group">
			<label>Password:</lable>
		</div>
		<div class="col-10 form-group">
			<input class="form-control" placeholder="Password" name="{{ .Password }}" type="password" value="">
		</div>

	</div>
	<div class="row"><div class="col-2 form-group"><label for="agent-totp">Authenticator:</label></div><div class="col-10 form-group"><input id="agent-totp" class="form-control" name="{{.TOTP}}" placeholder="Code or recovery code (if enabled)" autocomplete="one-time-code"></div></div>
	<div class="row">
		<div class="col alert alert-success">
			<button type="submit" class="btn btn-lg btn-success btn-block">Login In</button>
		</div>
    </div>
</div>
	</form>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="/admin/assets/js/vendor/jquery-slim.min.js"></script>
    <script src="/admin/assets/js/vendor/popper.min.js"></script>
    <script src="/admin/dist/js/bootstrap.min.js"></script>

  </body>
</html>
