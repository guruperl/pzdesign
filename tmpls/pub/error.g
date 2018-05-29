<!DOCTYPE html>
<html lang="en">
<head>

  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="Application Error Page">
  <meta name="keyword" content="Application Error Page">
  <!-- <link rel="shortcut icon" href="assets/ico/favicon.png"> -->

  <title>Application Error Page</title>

  <!-- Icons -->
  <link href="/1.0.8/vendors/css/font-awesome.min.css" rel="stylesheet">
  <link href="/1.0.8/vendors/css/simple-line-icons.min.css" rel="stylesheet">

  <!-- Main styles for this application -->
  <link href="/1.0.8/css/style.css" rel="stylesheet">

  <!-- Styles required by this views -->

</head>

<body class="app flex-row align-items-center">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-md-6">
        <div class="clearfix">
          <h1 class="float-left display-3 mr-4">{{ .Code }}</h1>
          <h4 class="pt-3">{{if or (or (or (eq .Code 400) (eq .Code 401)) (eq .Code 404)) (eq .Code 403)}}Oops! You're lost.{{else}}Application error.{{end}}</h4>
          <p class="text-muted">{{ .Errstr }}</p>
        </div>
{{if or (or (or (eq .Code 400) (eq .Code 401)) (eq .Code 404)) (eq .Code 403)}}<form>
        <div class="input-prepend input-group">
          <div class="input-group-prepend">
            <span class="input-group-text"><i class="fa fa-search"></i></span>
          </div>
          <input id="prependedInput" class="form-control" size="16" type="text" placeholder="What are you looking for?">
          <span class="input-group-append">
            <button class="btn btn-info" type="button">Search</button>
          </span>
        </div>
</form>{{end}}
      </div>
    </div>
  </div>

  <!-- Bootstrap and necessary plugins -->
  <script src="/1.0.8/vendors/js/jquery.min.js"></script>
  <script src="/1.0.8/vendors/js/popper.min.js"></script>
  <script src="/1.0.8/vendors/js/bootstrap.min.js"></script>

</body>
</html>
