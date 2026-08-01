{{ template "header" .}}
{{ template "balanceheader" .}}

        <div class="row">
            <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        {{index .ARGS.which 0}}
                    </div>
                    <div class="panel-body">
                        预算设置已提交。
                    </div>
                </div>
            </div>
        </div>

{{template "footer"}}
