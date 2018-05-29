Dear {{index .ARGS.firstname 0}} {{index .ARGS.lastname 0}}

Please visit the following URI to verify your email address and complete the publisher registration:
{{index .ARGS.serverUrl 0}}/goto/web/e/pub?action=activate&pub_id={{index .ARGS.pub_id 0}}&email={{index .ARGS.email_esc 0}}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname_esc 0}}&lastname={{index .ARGS.lastname_esc 0}}

PzAdx
