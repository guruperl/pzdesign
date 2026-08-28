{{ template "header" .}}
<div class="row"><div class="col-lg-12"><div class="panel panel-primary">
  <div class="panel-heading">Management API Credentials</div><div class="panel-body">
    <p>Credentials apply only to the public <code>/api/v1</code> interface and cannot be used for browser sign-in. A token is shown once; save it in a controlled secret-management system.</p>
    {{with .Other.IssuedToken}}<div class="alert alert-warning"><strong>Copy the new token now:</strong><br><code>{{.}}</code><br>It cannot be viewed again after you leave this page.</div>{{end}}
    {{with .Other.RevokedCredentialID}}<div class="alert alert-success">Credential {{.}} has been revoked.</div>{{end}}
    <h3>Issue Credential</h3>
    <form method="post" action="apicredential?action=issue">
      <input type="hidden" name="adv_id" value="{{.Other.APIAdvID}}">
      <div class="form-group"><label>Credential Name</label><input class="form-control" name="credential_name" maxlength="128" required></div>
      <div class="form-group"><label>Scopes</label>{{range .Other.APIScopes}}<div class="checkbox"><label><input type="checkbox" name="scope" value="{{.value}}"> {{.label}} (<code>{{.value}}</code>)</label></div>{{end}}</div>
      <div class="form-group"><label>Validity (Days)</label><input class="form-control" type="number" name="expires_days" min="1" max="365" value="90" required></div>
      <div class="form-group"><label>Reason</label><input class="form-control" name="reason" maxlength="255" required></div>
      <button class="btn btn-primary" type="submit">Issue Credential</button>
    </form>
    <hr><h3>Existing Credentials</h3>
    <div class="table-responsive"><table class="table table-striped table-bordered"><thead><tr><th>ID</th><th>Name</th><th>Public Identifier</th><th>Scopes</th><th>Expires</th><th>Last Used</th><th>Status and Actions</th></tr></thead><tbody>
    {{range .Other.APICredentials}}<tr><td>{{.ID}}</td><td>{{.Name}}</td><td><code>{{.PublicID}}</code></td><td>{{range .Scopes}}<code>{{.}}</code><br>{{end}}</td><td>{{.ExpiresAt}}</td><td>{{.LastUsedAt}}</td><td>
      {{if .RevokedAt}}Revoked{{else}}
      <form method="post" action="apicredential?action=rotate" style="margin-bottom:8px"><input type="hidden" name="adv_id" value="{{$.Other.APIAdvID}}"><input type="hidden" name="credential_id" value="{{.ID}}"><input name="reason" maxlength="255" placeholder="Rotation reason" required><button class="btn btn-xs btn-warning" type="submit">Rotate</button></form>
      <form method="post" action="apicredential?action=revoke"><input type="hidden" name="adv_id" value="{{$.Other.APIAdvID}}"><input type="hidden" name="credential_id" value="{{.ID}}"><input name="reason" maxlength="255" placeholder="Revocation reason" required><button class="btn btn-xs btn-danger" type="submit">Revoke</button></form>{{end}}
    </td></tr>{{else}}<tr><td colspan="7">No Management API credentials have been issued.</td></tr>{{end}}
    </tbody></table></div>
  </div>
</div></div></div>
{{ template "footer" .}}
