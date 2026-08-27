{{ template "header" .}}{{ template "advheader" }}
<h2>{{.Other.EmailSubject}}</h2>
<p>Hello,</p>
<p>Thank you for registering with W8M. Please click the link below to activate your advertiser account:</p>
<p><a href="{{.Other.ActivationLink}}">Activate Account</a></p>
<p>This link is valid for 24 hours. If you did not register, please ignore this email.</p>
<p>Best regards,<br/>W8M Advertising Platform</p>
{{ template "footer" }}
