{{ template "header" .}}{{ template "pubheader" }}
<h2>{{.Other.EmailSubject}}</h2>
<p>Hello,</p>
<p>You requested a password reset for your publisher account. Please click the link below to set a new password:</p>
<p><a href="{{.Other.ResetLink}}">Reset Password</a></p>
<p>This link is valid for 24 hours. If you did not request this, please ignore this email.</p>
<p>Best regards,<br/>W8M Advertising Platform</p>
{{ template "footer" }}
