{{ template "header" .}}
{{ template "paymentheader" .}}

<div class="row">
    <div class="col-lg-12">
    	<div class="panel panel-primary">
        		<div class="panel-body">
{{index .ARGS.amount 0}} added. We will notify you when it is successful.
				</div>
		</div>
	</div>
</div>

{{template "footer"}}
