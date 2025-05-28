{{ template "header" .}}
{{ template "advheader" .}}

<div class="row justify-content-center">
	<div class="col-md-6">
		<div class="card mx-4">
			<div class="card-body p-4">
            	<h1>商家注册</h1>
            	<p class="text-muted">请邮箱确认</p>
我们有份确认邮件送到你如下邮箱里：{{index .ARGS.email 0}}。
请点击其中链接确认。
			</div>
		</div>
	</div>
</div>

{{ template "footer" .}}


</body>
</html>

