{{template "header" .}}
{{template "targetnameheader" .}}

{{$pzAttrs := .Other.pzAttrsChinese}}
{{ $dAttrs := .Other.dAttrsChinese }}

<!-- /.row -->
			<div class="row">
				<div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            {{index .ARGS.campaign_name 0}}
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
<form class="form" method=post action=targetname>
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />
<input type=hidden name=action value="insert" />

                            <!-- Nav tabs -->
                            <ul class="nav nav-tabs">
                                <li class="active"><a href="#t1" data-toggle="tab">地域定向</a>
                                </li>
                                <li><a href="#t2" data-toggle="tab">系统平台</a>
                                </li>
                                <li><a href="#t3" data-toggle="tab">人群</a>
                                </li>
                                <li><a href="#t4" data-toggle="tab">自定义标签</a>
                                </li>
                                <li><a href="#t5" data-toggle="tab">时间定向</a>
                                </li>
                            </ul>

	<div class="tab-content">
		<div class="tab-pane fade in active" id="t1">
            <h3>省</h3>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= .Other.state}}
                        <input class="form-check-input" type=checkbox name=weekday value="{{$k}}" {{if index $v 1}}checked{{end}}>
                        <label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>

			<h3>市</h3>
			<div class="row">
				{{range $key, $val := .Other.city}}<div class="col-sm-2"><h4>{{$key}}</h4>
					<select name=city multiple>{{range $k, $v := $val}}
						<option {{if index $v 1}}selected{{end }} value="{{$k}}">{{index $v 0}}</option>{{end}}
					</select>
				</div>{{end}}
			</div>
		</div>

		<div class="tab-pane fade" id="t2">
			{{range $key, $val := .Other.pzuaChinese}}<h4>{{index $pzAttrs $key}}</h4>
			<select name={{$key}} multiple>{{range $k, $v := $val}}
				<option {{if index $v 1}}selected{{end }} value="{{$k}}">{{index $v 0}}</option>{{end}}
			</select>{{end}}
		</div>

		<div class="tab-pane fade" id="t3">
			{{range $key, $val := .Other.demoChinese}}<h4>{{index $dAttrs $key}}</h4>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= $val}}
                        <input class="form-check-input" type=checkbox name=weekday value="{{$k}}" {{if index $v 1}}checked{{end}}>
                        <label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>{{end}}
		</div>

		<div class="tab-pane fade" id="t4">
			<h3>自定义标签定向</h3>
			{{range $key, $val := .Other.custom}}<h4>{{$key}}</h4>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= $val}}
                        <input class="form-check-input" type=checkbox name=weekday value="{{$k}}" {{if index $v 1}}checked{{end}}>
                        <label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>{{end}}
		</div>

		<div class="tab-pane fade" id="t5">
			<h4>工作日定向</h4>
			<div class="form-group row">
			    <div class="col-sm-12">
			        <div class="form-check form-check-inline">{{range $k, $v:= .Other.weekdayChinese}}
						<input class="form-check-input" type=checkbox name=weekday value="{{$k}}" {{if index $v 1}}checked{{end}}>
						<label class="form-check-label">{{index $v 0}}</label>{{end}}
					</div>
				</div>
			</div>

			<h4>小时定向</h4>
			<div class="form-group row">
			    <div class="col-sm-12">
			        <div class="form-check form-check-inline">{{range $k, $v:= .Other.weekhour}}
						<input class="form-check-input" type=checkbox name=weekhour value="{{$k}}" {{if index $v 1}}checked{{end}}>
						<label class="form-check-label">{{index $v 0}}</label>{{end}}
					</div>
				</div>
			</div>
		</div>
	</div>

<p> </p>
							<div class="row">
								<div class="col-sm-2">
								</div>
								<div class="col-sm-4">
									<button class="btn btn-primary btn-lg btn-block" type=submit>保存</button>
								</div>
								<div class="col-sm-6">
								</div>
							</div>
</form>

						</div>
					</div>
				</div>
			</div>

{{template "footer"}}
