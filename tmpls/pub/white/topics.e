{{ template "header" .}}
{{ template "whiteheader" .}}

{{$args := .ARGS}}

          <div class="card">
            <div class="card-header">
			Review of Ad Item Candidates
            </div>
            <div class="card-body">

<form name=f1 class="form" method=post action="white">
<input type=hidden name=action value="insert" />
<input type=hidden name=slot_id value="{{index .ARGS.slot_id 0}}" />
<input type=hidden name=slot_md5 value="{{index .ARGS.slot_md5 0}}" />
<input type=hidden name=slot_name value="{{index .ARGS.slot_name 0}}" />

<div class="table-responsive">
<table class="table table-border table-striped">
              <thead>
                <tr>
                  <th>Campaign</th>
                  <th>Item</th>
                  <th></th>
                  <th>Check</th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr>
<td>{{.campaign_name}}</td>
<td>{{.item_name}}</td>
<td> </td>
<td><input type=checkbox class="form-check-input" name=item_id value="{{.item_id}}">
</tr>{{end}}{{end}}
</tobdy>
</table>
</div>
<button class="btn btn-primary" type=submit> Submit </button>
</form>
            </div>
          </div>


{{ template "footer" }}
</body>
</html>

