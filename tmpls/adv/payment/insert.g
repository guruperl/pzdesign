{{ template "header" .}}
{{ template "paymentheader" .}}

<div class="row">
    <div class="col-lg-12">
        <div class="panel panel-primary">
                <div class="panel-body">
您要充值{{index .ARGS.amount 0}}元。请等待我们后台审核，审核通过后我们将通知您！
                </div>
        </div>
    </div>
</div>


{{template "footer"}}
