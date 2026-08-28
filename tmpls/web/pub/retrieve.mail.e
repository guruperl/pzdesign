{{ $item := index .Lists 0 }}
Hello, {{$item.lastname}} {{$item.firstname}}:

We received a password reset request for your W8M publisher account. Use the following link to set a new password:
{{index .ARGS.serverUrl 0}}/goto/web/e/pub?action=startreset&pub_id={{$item.pub_id}}&email={{index .ARGS.email 0 | urlquery }}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0 | urlquery }}&lastname={{index .ARGS.lastname 0 | urlquery }}

If you did not initiate this request, you can ignore this email.

W8M Advertising Platform
