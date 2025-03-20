{{template "header" .}}
{{template "targetnameheader" .}}

{{ $second := .Other.second }}

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
<input type=hidden name=item_id value="{{index .ARGS.item_id 0}}" />
<input type=hidden name=item_md5 value="{{index .ARGS.item_md5 0}}" />
<input type=hidden name=item_name value="{{index .ARGS.item_name 0}}" />
<input type=hidden name=action value="insert" />

                            <!-- Nav tabs -->
                            <ul class="nav nav-tabs">
<li class="active"><a href="#t1" data-toggle="tab">地域定向</a></li>
<li><a href="#t5" data-toggle="tab">时间定向</a></li>
<li><a href="#t2" data-toggle="tab">系统平台</a></li>
<li><a href="#t3" data-toggle="tab">人口属性</a></li>
<li><a href="#t6" data-toggle="tab">行业投放</a></li>
<li><a href="#t4" data-toggle="tab">自定义标签</a></li>
                            </ul>

	<div class="tab-content">
		<div class="tab-pane fade" id="t6">
			<h3>所要媒体行业</h3>
			<div class="form-group row">
                <div class="col-sm-12">
					<input class="form-control-inline" type=radio name=channel_order value="Black" {{if eq "Black" .Other.channel_order}}checked{{end}} />黑名单
					<input type=radio name=channel_order value="White" {{if eq "White" .Other.channel_order}}checked{{end}} />白名单
				</div>
			</div>
			{{ with .Other.chac_topics }}{{ range . }}
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">
                       <input class="form-control-inline" name=ac_ids {{if .chac_id}}checked{{end}} type=checkbox value="{{.channel_id}}" />
                        <label class="form-check-label">{{.channel_name_g}}</label>
					</div>
				</div>
			</div>{{end}}
            {{end}}
		</div>

		<div class="tab-pane fade in active" id="t1">
            <h3>省</h3>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= .Other.state}}
                        <input class="form-check-input" type=checkbox name=state value="{{$k}}" {{if index $v 1}}checked{{end}}>
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

            <h3>运营商</h3>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= .Other.isp}}
                        <input class="form-check-input" type=checkbox name=isp value="{{$k}}" {{if index $v 1}}checked{{end}}>
                        <label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>
		</div>

		<div class="tab-pane fade" id="t2">{{range $key, $val := .Other.pzuaChinese}}
			<h4>{{$key}}</h4>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v := $val}}
						<input class="form-check-input" type=checkbox name={{$key}} {{if index $v 1}}checked{{end }} value="{{$k}}" />
						<label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>{{end}}
		</div>

		<div class="tab-pane fade" id="t3">{{range $key, $val := .Other.demoChinese}}
			<h4>{{$key}}</h4>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= $val}}
                        <input class="form-check-input" type=checkbox name="{{$key}}" {{if index $v 1}}checked{{end}} value="{{$k}}" />
                        <label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>{{end}}
		</div>

		<div class="tab-pane fade" id="t5">{{range $key, $val := .Other.dtChinese}}
			<h4>{{$key}}</h4>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= $val}}
                        <input class="form-check-input" type={{if eq $key "utcoffset"}}radio{{else}}checkbox{{end}} name="{{$key}}" {{if index $v 1}}checked{{end}} value="{{$k}}" />
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
                        <input class="form-check-input" type=checkbox name="{{$key}}" value="{{$k}}" {{if index $v 1}}checked{{end}}>
                        <label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>{{end}}
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
