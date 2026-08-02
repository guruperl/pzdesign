{{ template "header" .}}
{{ template "pubheader" .}}

{{$item := index .Lists 0}}
<h3>卖方透明度审核</h3>
<form class="form" action="pub" method="post">
<input type="hidden" name="action" value="update" />
<input type="hidden" name="pub_id" value="{{$item.pub_id}}" />
<div class="form-group row"><label class="col-sm-2 col-form-label">卖方 ID</label><div class="col-sm-4"><input class="form-control" name="seller_id" maxlength="64" value="{{$item.seller_id}}" /></div><label class="col-sm-2 col-form-label">关系</label><div class="col-sm-4"><select class="form-control" name="seller_type"><option value="Publisher" {{if eq $item.seller_type "Publisher"}}selected{{end}}>直接媒体所有者</option><option value="Intermediary" {{if eq $item.seller_type "Intermediary"}}selected{{end}}>代理销售 / 转售方</option></select></div></div>
<div class="form-group row"><label class="col-sm-2 col-form-label">广告系统域名（ASI）</label><div class="col-sm-4"><input class="form-control" name="seller_asi" value="{{$item.seller_asi}}" /></div><label class="col-sm-2 col-form-label">企业域名</label><div class="col-sm-4"><input class="form-control" name="seller_domain" value="{{$item.seller_domain}}" /></div></div>
<div class="form-group row"><label class="col-sm-2 col-form-label">公开企业名称</label><div class="col-sm-4"><input class="form-control" name="seller_name" value="{{$item.seller_name}}" /></div><label class="col-sm-2 col-form-label">审核</label><div class="col-sm-4"><select class="form-control" name="seller_authorized"><option value="No" {{if eq $item.seller_authorized "No"}}selected{{end}}>未授权披露</option><option value="Yes" {{if eq $item.seller_authorized "Yes"}}selected{{end}}>授权披露</option></select></div></div>
<div class="form-group"><label for="seller-review-reason">审核原因</label><input id="seller-review-reason" class="form-control" name="reason" maxlength="255" required><small class="form-text text-muted">记录本次授权、拒绝或重新审核的依据；请勿填写凭据或私有合同内容。</small></div>
<p>“授权披露”只允许服务端生成卖方和供应链声明；不会更改结算账户。转售记录在没有已审核上游节点时生成 <code>complete=0</code>。</p>
<button type="submit" class="btn btn-primary">保存审核结果</button>
</form>

{{ template "footer" .}}
