{{ template "header" .}}
{{ template "pubheader" .}}

{{$item := index .Lists 0}}
<h3>Seller Transparency Review</h3>
<form class="form" action="pub" method="post">
<input type="hidden" name="action" value="update" />
<input type="hidden" name="pub_id" value="{{$item.pub_id}}" />
<div class="form-group row"><label class="col-sm-2 col-form-label">Seller ID</label><div class="col-sm-4"><input class="form-control" name="seller_id" maxlength="64" value="{{$item.seller_id}}" /></div><label class="col-sm-2 col-form-label">Relationship</label><div class="col-sm-4"><select class="form-control" name="seller_type"><option value="Publisher" {{if eq $item.seller_type "Publisher"}}selected{{end}}>Direct Publisher</option><option value="Intermediary" {{if eq $item.seller_type "Intermediary"}}selected{{end}}>Sales Agent / Reseller</option></select></div></div>
<div class="form-group row"><label class="col-sm-2 col-form-label">Advertising System Domain (ASI)</label><div class="col-sm-4"><input class="form-control" name="seller_asi" value="{{$item.seller_asi}}" /></div><label class="col-sm-2 col-form-label">Business Domain</label><div class="col-sm-4"><input class="form-control" name="seller_domain" value="{{$item.seller_domain}}" /></div></div>
<div class="form-group row"><label class="col-sm-2 col-form-label">Public Business Name</label><div class="col-sm-4"><input class="form-control" name="seller_name" value="{{$item.seller_name}}" /></div><label class="col-sm-2 col-form-label">Review</label><div class="col-sm-4"><select class="form-control" name="seller_authorized"><option value="No" {{if eq $item.seller_authorized "No"}}selected{{end}}>Disclosure Not Authorized</option><option value="Yes" {{if eq $item.seller_authorized "Yes"}}selected{{end}}>Disclosure Authorized</option></select></div></div>
<div class="form-group"><label for="seller-review-reason">Review Reason</label><input id="seller-review-reason" class="form-control" name="reason" maxlength="255" required><small class="form-text text-muted">Record the basis for this authorization, rejection, or renewed review. Do not enter credentials or private contract content.</small></div>
<p>“Disclosure Authorized” permits only server-generated seller and supply-chain declarations; it does not change the settlement account. A resale record without a reviewed upstream node is generated with <code>complete=0</code>.</p>
<button type="submit" class="btn btn-primary">Save Review Result</button>
</form>

{{ template "footer" .}}
