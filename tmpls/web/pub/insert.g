{{ template "header" .}}
{{ template "pubheader" .}}

<div class="row justify-content-center">
	<div class="col-md-6">
		<div class="card mx-4">
			<div class="card-body p-4">
            	<h1>流量源注册</h1>
            	<p class="text-muted">请确认</p>
有份邮件送到你的邮箱地址 {{index .ARGS.email 0}}。
请点击其中链接确认地址正确。
			</div>
		</div>
	</div>
</div>

{{ template "footer" .}}


</body>
</html>

