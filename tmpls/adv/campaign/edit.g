{{ template "header" .}}
{{ template "campaignheader" .}}

{{$item := index .Lists 0}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            修改活动推广计划
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form method=post action=campaign>
<input type=hidden name="action" value="update" />
<input type=hidden name="campaign_id" value="{{$item.campaign_id}}" />

<div class="form-group row">
	<label for="inputCampaigName" class="col-sm-3 col-form-label">活动名称:</label>
	<div class="col-sm-9">
		<input type=text class="form-control" name="campaign_name" value="{{$item.campaign_name}}" placeholder="Name of Campaign" />
	</div>
</div>

<div class="form-group row">
	<label for="tableFrequencyCap" class="col-sm-3 col-form-label">频次控制:</label>
	<div class="col-sm-9">
<table>
<tr><th>类型</th><th>数值</th><th>周期</th><th>间隔</th></tr>
<tr><td>曝光次数: </td>
<td><input type=text name=cpm_fc value="{{$item.cpm_fc}}" size=3></td>
<td><input type=text name=cpm_length value="{{$item.cpm_length}}" size=6>分钟</td>
<td><input type=text name=cpm_throttle value="{{$item.cpm_throttle}}" size=6>分钟</td></tr>
<tr><td>点击次数: </td>
<td><input type=text name=cpc_fc value="{{$item.cpc_fc}}" size=3></td>
<td><input type=text name=cpc_length value="{{$item.cpc_fc}}" size=6>分钟</td>
<td></td></tr>
</table>
	</div>
</div>

<div class="form-group row">
	<label for="inputPageCap" class="col-sm-3 col-form-label">单页创意数:</label>
	<div class="col-sm-9">
		<input type=text class="form-control-sm" name="page_cap" value="{{$item.page_cap}}" placeholder="campaign items on a page" />
	</div>
</div>

<div class="form-group row">
	<label for="tableBudget" class="col-sm-3 col-form-label">预算:</label>
	<div class="col-sm-9">
		<a class="btn btn-xs btn-warning" href="balance?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">查看</a>
	</div>
</div>

<div class="form-group row">
	<label for="inputAccessOrder" class="col-sm-3 col-form-label">黑白名单:</label>
	<div class="col-sm-9">
		<div class="form-check form-check-inline">
			{{$item.access_order}}
			<a class="btn btn-xs btn-warning" href="ac?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">查看</a>
		</div>
	</div>
</div>

<div class="form-group row">
    <label for="selectCampaignQuality" class="col-sm-3 col-form-label">本活动质量:</label>
    <div class="col-sm-9">
        <div class="panel panel-primary">
            <div class="panel-body">
<table>{{range $key, $val := .Other.campaigns }}{{$obs := index $item $key}}
<tr><th>{{$key}}:</th><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-3 col-form-label">可接受网站质量:</label>
    <div class="col-sm-9">
        <div class="panel panel-primary">
            <div class="panel-body">
<table>{{range $key, $val := .Other.sites }}{{$obs := index $item $key}}
<tr><th>{{$key}}:</th><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-3 col-form-label">行业设置:</label>
    <div class="col-sm-9">
		<div class="panel panel-primary">
			<div class="panel-body">
<table>
<tr>
<th>行业名</th>
<th>所属行业&nbsp; </th>
<th>黑白次序: {{$item.channel_order}}
</th>
</tr>
<tbody>{{ with $item.chac_topics }}{{ range . }}{{if or .chac_id .chbelong_id}}
<tr><td>{{.channel_name}}</td>
<td>{{if .chac_id}}Selected{{end}}</td>
<td>{{if .chbelong_id}}Selected{{end}}</td>
</tr>{{end}}{{end}}{{end}}
</tobdy>
</table>
            <a class="btn btn-xs btn-warning" href="chac?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">查看</a>
			</div>
		</div>
	</div>
</div>

<div class="form-group row">
	<div class="col-sm-9">
<button type="submit" class="btn btn-primary">更新!</button>
	</div>
</div>

</form>

                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->
{{template "footer"}}
