{{ template "header" .}}
{{ template "pubheader" .}}

{{$item := index .Lists 0}}

          <div class="card">
            <div class="card-header">
              更新账户基本信息
            </div>
            <div class="card-body">

<form name=form1 class="form" action="pub" method=post>
<input type=hidden name=action value="update" />

<div class="form-group row">
    <label for="inputDomain" class="col-sm-3 col-form-label">域名:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=domain value="{{$item.domain}}" />
    </div>
</div>

<div class="card mb-3">
  <div class="card-header">卖方透明度信息</div>
  <div class="card-body">
    <p>这些字段用于 <code>sellers.json</code> / <code>source.schain</code> 对账与披露，不会改变当前流量方账户的结算归属。修改后需平台重新审核。</p>
    <div class="form-group row">
      <label class="col-sm-3 col-form-label">卖方 ID：</label><div class="col-sm-3"><input class="form-control" name="seller_id" maxlength="64" value="{{$item.seller_id}}" /></div>
      <label class="col-sm-2 col-form-label">关系：</label><div class="col-sm-4"><select class="form-control" name="seller_type"><option value="Publisher" {{if eq $item.seller_type "Publisher"}}selected{{end}}>直接媒体所有者</option><option value="Intermediary" {{if eq $item.seller_type "Intermediary"}}selected{{end}}>代理销售 / 转售方</option></select></div>
    </div>
    <div class="form-group row">
      <label class="col-sm-3 col-form-label">广告系统域名（ASI）：</label><div class="col-sm-3"><input class="form-control" name="seller_asi" value="{{$item.seller_asi}}" placeholder="w8m.com" /></div>
      <label class="col-sm-2 col-form-label">企业域名：</label><div class="col-sm-4"><input class="form-control" name="seller_domain" value="{{$item.seller_domain}}" /></div>
    </div>
    <div class="form-group row mb-0">
      <label class="col-sm-3 col-form-label">公开企业名称：</label><div class="col-sm-5"><input class="form-control" name="seller_name" maxlength="255" value="{{$item.seller_name}}" /></div>
      <div class="col-sm-4 col-form-label">审核状态：{{if eq $item.seller_authorized "Yes"}}已审核{{else}}待审核{{end}}</div>
    </div>
  </div>
</div>

<div class="form-group row">
    <label for="inputFirstName" class="col-sm-3 col-form-label">姓名:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name=lastname value="{{$item.lastname}}" />
    </div>
    <div class="col-sm-6">
        <input type=text class="form-control" name=firstname value="{{$item.firstname}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputCompany" class="col-sm-3 col-form-label">公司名:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=company value="{{$item.company}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputPhone" class="col-sm-3 col-form-label">电话号码:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=phone value="{{$item.phone}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputStreet" class="col-sm-3 col-form-label">路牌和号码:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=street value="{{$item.street}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputCity" class="col-sm-3 col-form-label">城市:</label>
    <div class="col-sm-6">
        <input type=text class="form-control" name=city value="{{$item.city}}" />
    </div>
    <div class="col-sm-2">
        <select class="form-control" name=state_id>
<option value=""></option>{{range .Other.address_states}}{{with .}}
<option {{if $item.state_id}}{{if eq .state_id $item.state_id}}selected{{end}}{{end}} value={{.state_id}}>{{.state_name}}</option>
{{end}}{{end}}</select>
    </div>
</div>

<div class="form-group row">
    <label for="inputState" class="col-sm-3 col-form-label"> </label>
    <div class="col-sm-8">
        <button type=submit class="btn btn-primary">保存并更新</button>
    </div>
</div>

</form>

</div>
</div>

{{ template "footer" }}

</body>
</html>
