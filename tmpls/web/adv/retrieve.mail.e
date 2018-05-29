{{ $item := index .Lists 0 }}
Dear {{$item.firstname}} {{$item.lastname}}:

Please visit the following URI to reset advertiser password:
{{index .ARGS.serverUrl 0}}/goto/web/e/adv?action=startreset&adv_id={{$item.adv_id}}&email={{index .ARGS.email_esc 0}}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname_esc 0}}&lastname={{index .ARGS.lastname_esc 0}}

PzAdx
