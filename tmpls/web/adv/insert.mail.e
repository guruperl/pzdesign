Hello, {{index .ARGS.lastname 0}} {{index .ARGS.firstname 0}}:

You are registering a W8M advertiser account. Use the following link to verify your email and complete account registration:
{{index .ARGS.serverUrl 0}}/goto/web/e/adv?action=activate&adv_id={{index .ARGS.adv_id 0}}&email={{index .ARGS.email 0|urlquery}}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0|urlquery}}&lastname={{index .ARGS.lastname 0|urlquery}}

If you did not initiate this request, you can ignore this email.

W8M Advertising Platform
