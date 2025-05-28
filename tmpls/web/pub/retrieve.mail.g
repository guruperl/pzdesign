{{ $item := index .Lists 0 }}
流量源公司家 {{$item.lastname}}{{$item.firstname}}:

你好!

请点击如下链接重新设置密码：
{{index .ARGS.serverUrl 0}}/goto/web/g/pub?action=startreset&pub_id={{$item.pub_id}}&email={{index .ARGS.email 0 | urlquery }}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0 | urlquery }}&lastname={{index .ARGS.lastname 0 | urlquery }}

W8M 广告平台
