Dear {{index .ARGS.firstname 0}} {{index .ARGS.lastname 0}}

Please visit the following URI to verify your email address and complete the publisher registration:
{{index .ARGS.serverUrl 0}}/goto/web/e/pub?action=activate&pub_id={{index .ARGS.pub_id 0}}&email={{index .ARGS.email 0 | urlquery }}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0 | urlquery }}&lastname={{index .ARGS.lastname 0 | urlquery }}

PzAdx
