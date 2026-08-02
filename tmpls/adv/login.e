<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Advertiser Logs In</title>

    <!-- Bootstrap Core CSS -->
    <link href="/sb2/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- MetisMenu CSS -->
    <link href="/sb2/vendor/metisMenu/metisMenu.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="/sb2/dist/css/sb-admin-2.css" rel="stylesheet">

    <!-- Custom Fonts -->
    <link href="/sb2/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">


</head>

<body>

    <div class="container">
        <div class="row">
            <div class="col-md-4 col-md-offset-4">
                <div class="login-panel panel panel-primary">
                    <div class="panel-heading">
                        <h3 class="panel-title">Please Sign In</h3>
                    </div>
                    <div class="panel-body">
         <form role="form" METHOD="POST" ACTION="/goto/adv/e/{{ .LoginName }}">
	<INPUT TYPE="HIDDEN" NAME="{{ .GoURIName }}" VALUE="{{ .GoURI }}">
                            <fieldset>
								<div class="alert alert-success">
                                {{ .Errorstr }}
                            	</div>
                                <div class="form-group">
                                    <input class="form-control" placeholder="E-mail" name="{{.Login}}" type="email" autofocus>
                                </div>
                                <div class="form-group">
                                    <input class="form-control" placeholder="Password" name="{{ .Password }}" type="password" value="">
                                </div>
                                <div class="form-group"><input class="form-control" placeholder="Authenticator or recovery code (if enabled)" name="{{.TOTP}}" type="text" autocomplete="one-time-code"></div>
                                <!-- div class="checkbox">
                                    <label>
                                        <input name="remember" type="checkbox" value="Remember Me">Remember Me
                                    </label>
                                </div -->
                                <!-- Change this to a button or input when using this as a form -->
                                <button type="submit" class="btn btn-lg btn-success btn-block">Login</button>
                            </fieldset>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="/sb2/vendor/jquery/jquery.min.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="/sb2/vendor/bootstrap/js/bootstrap.min.js"></script>

    <!-- Metis Menu Plugin JavaScript -->
    <script src="/sb2/vendor/metisMenu/metisMenu.min.js"></script>

    <!-- Custom Theme JavaScript -->
    <script src="/sb2/dist/js/sb-admin-2.js"></script>

</body>

</html>
