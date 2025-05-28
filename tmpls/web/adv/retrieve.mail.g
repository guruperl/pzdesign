{{ $item := index .Lists 0 }}
流量源公司 {{$item.firstname}} {{$item.lastname}}:

你好!

请访问如下网站重新设置商家密码：
{{index .ARGS.serverUrl 0}}/goto/web/g/adv?action=startreset&adv_id={{$item.adv_id}}&email={{index .ARGS.email 0|urlquery}}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0|urlquery}}&lastname={{index .ARGS.lastname 0|urlquery}}

W8M 
