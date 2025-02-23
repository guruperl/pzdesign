{{ $item := index .Lists 0 }}
Dear {{$item.firstname}} {{$item.lastname}}:

Please visit the following URI to reset publisher password:
{{index .ARGS.serverUrl 0}}/goto/web/e/pub?action=startreset&pub_id={{$item.pub_id}}&email={{index .ARGS.email 0 | urlquery }}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0 | urlquery }}&lastname={{index .ARGS.lastname 0 | urlquery }}

W8M
