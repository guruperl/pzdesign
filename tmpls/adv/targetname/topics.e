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
<form name=form1 class="form" method=post action=targetname>
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />
<input type=hidden name=item_id value="{{index .ARGS.item_id 0}}" />
<input type=hidden name=item_md5 value="{{index .ARGS.item_md5 0}}" />
<input type=hidden name=item_name value="{{index .ARGS.item_name 0}}" />
<input type=hidden name=action value="insert" />

                            <!-- Nav tabs -->
                            <ul class="nav nav-tabs">
<li class="active"><a href="#t1" data-toggle="tab">Geographic Targeting</a></li>
<li><a href="#t5" data-toggle="tab">Time Targeting</a></li>
<li><a href="#t2" data-toggle="tab">System Platform</a></li>
<li><a href="#t3" data-toggle="tab">Demographics</a></li>
<li><a href="#t6" data-toggle="tab">Industry Targeting</a></li>
<li><a href="#t7" data-toggle="tab">Bundle or Domain</a></li>
<li><a href="#t4" data-toggle="tab">Attribute Targeting</a></li>
                            </ul>

    <div class="tab-content">
        <div class="tab-pane fade" id="t7">
            <h3>Traffic-Type Targeting</h3>
            <h4>Traffic Type</h4>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type=radio name=fl_sitetypes {{if eq .Other.aclSiteTypes "App,Web"}}checked{{end }} value="App,Web" />
                        <label class="form-check-label">All</label>
                        <input class="form-check-input" type=radio name=fl_sitetypes {{if eq .Other.aclSiteTypes "App"}}checked{{end }} value="App" />
                        <label class="form-check-label">App</label>
                        <input class="form-check-input" type=radio name=fl_sitetypes {{if eq .Other.aclSiteTypes "Web"}}checked{{end }} value="Web" />
                        <label class="form-check-label">Website</label>
                    </div>
                </div>
            </div>
            <h4>Traffic Source</h4>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type=radio name=acess_order {{if eq .Other.orderSiteTypes "White"}}checked{{end }} value="White" />
                        <label class="form-check-label">Allowlist</label>
                        <input class="form-check-input" type=radio name=access_order {{if eq .Other.orderSiteTypes "Black"}}checked{{end }} value="Black" />
                        <label class="form-check-label">Blocklist</label>
                        <input class="form-check-input" type=radio name=access_order {{if eq .Other.orderSiteTypes "Inherit"}}checked{{end }} value="Inherit" />
                        <label class="form-check-label">Inherit Campaign Setting</label>
                    </div>
                </div>{{range $k, $v := .Other.acl}}
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type=checkbox name=site_id {{if index $v 0}}checked{{end }} value="{{$k}}" />
                        <label class="form-check-label">{{index $v 1}} <em>{{index $v 2 }}</em>  <strong style="color:red">{{index $v 3}}</strong></label>
                    </div>
                </div>{{end}}
            </div>
        </div>

        <div class="tab-pane fade" id="t6">
            <h3>Traffic Source Industries</h3>
            <div class="form-group row">
                <div class="col-sm-12">
                    <input class="form-control-inline" type=radio name=channel_order value="Black" {{if eq "Black" .Other.channel_order}}checked{{end}} />Blocklist
                    <input type=radio name=channel_order value="White" {{if eq "White" .Other.channel_order}}checked{{end}} />Allowlist
                </div>
            </div>
            {{ with .Other.chac_topics }}{{ range . }}
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">
                       <input class="form-control-inline" name=ac_ids {{if .chac_id}}checked{{end}} type=checkbox value="{{.channel_id}}" />
                        <label class="form-check-label">{{.channel_name}}</label>
                    </div>
                </div>
            </div>{{end}}
            {{end}}
        </div>

        <div class="tab-pane fade in active" id="t1">
            <h3>Country</h3>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= .Other.country}}
                        <input class="form-check-input" type=checkbox name=country value="{{$k}}" {{if index $v 1}}checked{{end}}>
                        <label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>

            <h3>State / Province</h3>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= .Other.state}}
                        <input class="form-check-input" type=checkbox name=state value="{{$k}}" {{if index $v 1}}checked{{end}}>
                        <label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>

            <h3>City</h3>
            <div class="row">
                {{range $key, $val := .Other.city}}<div class="col-sm-2"><h4>{{$key}}</h4>
                    <select name=city multiple>{{range $k, $v := $val}}
                        <option {{if index $v 1}}selected{{end }} value="{{$k}}">{{index $v 0}}</option>{{end}}
                    </select>
                </div>{{end}}
            </div>

            <h3>Network Operator</h3>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= .Other.isp}}
                        <input class="form-check-input" type=checkbox name=isp value="{{$k}}" {{if index $v 1}}checked{{end}}>
                        <label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>
        </div>

        <div class="tab-pane fade" id="t2">{{range $key, $val := .Other.pzua}}
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

        <div class="tab-pane fade" id="t3">{{range $key, $val := .Other.demo}}
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

        <div class="tab-pane fade" id="t5">{{range $key, $val := .Other.dt}}
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
            <h3>Uploaded-Attribute Targeting</h3>
            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">{{range $k, $v:= .Other.upload}}
                        <input class="form-check-input" type=checkbox name="uploads" {{if index $v 1}}checked{{end}} value="{{$k}}" />
                        <label class="form-check-label">{{index $v 0}}</label>{{end}}
                    </div>
                </div>
            </div>

<p> &nbsp </p>
            <h3>Custom-Attribute Targeting</h3>
            <h4>First define the attribute names and allowed values under Attribute Management / Custom Attributes in the left navigation.</h4>
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

<p> &nbsp </p>
<p> </p>
                            <div class="row">
                                <div class="col-sm-2">
                                </div>
                                <div class="col-sm-4">
                                    <button class="btn btn-primary btn-lg btn-block" type=submit>Save</button>
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
