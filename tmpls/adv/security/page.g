{{ template "header" .}}
{{ template "advheader" .}}
<div class="panel panel-default"><div class="panel-heading"><h3 class="panel-title">账户安全</h3></div><div class="panel-body">
{{if .Other.Required}}<div class="alert alert-info">此类账户必须启用双重验证。完成设置前，系统只允许访问账户安全页面。</div>{{end}}
{{if .Other.Disabled}}<div class="alert alert-success">双重验证已停用，现有会话已撤销。请重新登录并尽快重新设置。</div>{{end}}
{{with .Other.Enrollment}}<div class="alert alert-warning"><p>请在身份验证器中添加以下密钥，然后输入当前六位验证码确认。密钥只在本页显示一次。</p><p><strong>设置密钥：</strong> <code>{{.Secret}}</code></p><p class="text-break"><strong>标准 TOTP 地址：</strong> <code>{{.URI}}</code></p></div>
<form method="post" action="security">{{$.Other.CSRFInput}}<input type="hidden" name="action" value="confirm"><div class="form-group"><label for="security-confirm-code">六位验证码</label><input id="security-confirm-code" class="form-control" name="totp" inputmode="numeric" autocomplete="one-time-code" pattern="[0-9]{6}" required></div><button class="btn btn-primary" type="submit">确认并启用</button></form>{{end}}
{{with .Other.RecoveryCodes}}<div class="alert alert-success"><p><strong>请立即离线保存这些恢复代码。</strong> 每个代码只能使用一次，离开本页后系统不会再次显示。</p><ul>{{range .}}<li><code>{{.}}</code></li>{{end}}</ul></div>{{end}}
<p>当前状态：<strong>{{.Other.MFAState}}</strong>；未使用恢复代码：<strong>{{.Other.RecoveryRemaining}}</strong></p>
{{if eq .Other.MFAState "Disabled"}}<form method="post" action="security">{{.Other.CSRFInput}}<input type="hidden" name="action" value="enroll"><button class="btn btn-primary" type="submit">设置身份验证器</button></form>{{end}}
{{if eq .Other.MFAState "Enabled"}}<hr><h4>更新恢复代码</h4><p>更新后，之前的恢复代码立即失效。</p><form method="post" action="security">{{.Other.CSRFInput}}<input type="hidden" name="action" value="rotateRecovery"><div class="form-group"><label for="security-rotate-code">当前六位验证码</label><input id="security-rotate-code" class="form-control" name="totp" inputmode="numeric" autocomplete="one-time-code" pattern="[0-9]{6}" required></div><button class="btn btn-default" type="submit">生成新的恢复代码</button></form>
<hr><h4>停用双重验证</h4><p>此操作会撤销所有会话，并记录操作原因。</p><form method="post" action="security">{{.Other.CSRFInput}}<input type="hidden" name="action" value="disable"><div class="form-group"><label for="security-disable-code">当前六位验证码</label><input id="security-disable-code" class="form-control" name="totp" inputmode="numeric" autocomplete="one-time-code" pattern="[0-9]{6}" required></div><div class="form-group"><label for="security-disable-reason">操作原因</label><input id="security-disable-reason" class="form-control" name="reason" maxlength="255" required></div><button class="btn btn-danger" type="submit">停用并退出所有会话</button></form>{{end}}
</div></div>
{{ template "footer" .}}
