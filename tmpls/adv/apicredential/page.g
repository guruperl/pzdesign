{{ template "header" .}}
<div class="row"><div class="col-lg-12"><div class="panel panel-primary">
  <div class="panel-heading">管理 API 凭证</div><div class="panel-body">
    <p>凭证只适用于公开的 <code>/api/v1</code> 接口，不能用于网页登录。令牌只显示一次，请保存到受控的密钥管理系统。</p>
    {{with .Other.IssuedToken}}<div class="alert alert-warning"><strong>请立即复制新令牌：</strong><br><code>{{.}}</code><br>离开本页后无法再次查看。</div>{{end}}
    {{with .Other.RevokedCredentialID}}<div class="alert alert-success">凭证 {{.}} 已撤销。</div>{{end}}
    <h3>签发凭证</h3>
    <form method="post" action="apicredential?action=issue">
      <input type="hidden" name="adv_id" value="{{.Other.APIAdvID}}">
      <div class="form-group"><label>凭证名称</label><input class="form-control" name="credential_name" maxlength="128" required></div>
      <div class="form-group"><label>权限范围</label>{{range .Other.APIScopes}}<div class="checkbox"><label><input type="checkbox" name="scope" value="{{.value}}"> {{.label}}（<code>{{.value}}</code>）</label></div>{{end}}</div>
      <div class="form-group"><label>有效期（天）</label><input class="form-control" type="number" name="expires_days" min="1" max="365" value="90" required></div>
      <div class="form-group"><label>操作原因</label><input class="form-control" name="reason" maxlength="255" required></div>
      <button class="btn btn-primary" type="submit">签发凭证</button>
    </form>
    <hr><h3>现有凭证</h3>
    <div class="table-responsive"><table class="table table-striped table-bordered"><thead><tr><th>ID</th><th>名称</th><th>公开标识</th><th>权限</th><th>到期时间</th><th>最近使用</th><th>状态与操作</th></tr></thead><tbody>
    {{range .Other.APICredentials}}<tr><td>{{.ID}}</td><td>{{.Name}}</td><td><code>{{.PublicID}}</code></td><td>{{range .Scopes}}<code>{{.}}</code><br>{{end}}</td><td>{{.ExpiresAt}}</td><td>{{.LastUsedAt}}</td><td>
      {{if .RevokedAt}}已撤销{{else}}
      <form method="post" action="apicredential?action=rotate" style="margin-bottom:8px"><input type="hidden" name="adv_id" value="{{$.Other.APIAdvID}}"><input type="hidden" name="credential_id" value="{{.ID}}"><input name="reason" maxlength="255" placeholder="轮换原因" required><button class="btn btn-xs btn-warning" type="submit">轮换</button></form>
      <form method="post" action="apicredential?action=revoke"><input type="hidden" name="adv_id" value="{{$.Other.APIAdvID}}"><input type="hidden" name="credential_id" value="{{.ID}}"><input name="reason" maxlength="255" placeholder="撤销原因" required><button class="btn btn-xs btn-danger" type="submit">撤销</button></form>{{end}}
    </td></tr>{{else}}<tr><td colspan="7">尚未签发管理 API 凭证。</td></tr>{{end}}
    </tbody></table></div>
  </div>
</div></div></div>
{{ template "footer" .}}
