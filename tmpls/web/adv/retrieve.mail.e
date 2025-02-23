{{ $item := index .Lists 0 }}
Dear {{$item.firstname}} {{$item.lastname}}:

Please visit the following URI to reset advertiser password:
{{index .ARGS.serverUrl 0}}/goto/web/e/adv?action=startreset&adv_id={{$item.adv_id}}&email={{index .ARGS.email 0|urlquery}}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0|urlquery}}&lastname={{index .ARGS.lastname 0|urlquery}}

W8M
