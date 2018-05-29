{{ template "header" .}}
{{ template "pubheader" .}}

<div class="row justify-content-center">
	<div class="col-md-6">
		<div class="card mx-4">
			<div class="card-body p-4">
            	<h1>Publisher Registration</h1>
            	<p class="text-muted">Confirm your application</p>
We sent an email confirmation to your address {{index .ARGS.email 0}}.
please open it and complete your registration.
			</div>
		</div>
	</div>
</div>

{{ template "footer" .}}


</body>
</html>

