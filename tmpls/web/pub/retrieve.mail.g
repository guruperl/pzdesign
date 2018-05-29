{{ $item := index .Lists 0 }}
媒体商家 {{$item.lastname}}{{$item.firstname}}:

你好!

请点击如下链接重新设置密码：
{{index .ARGS.serverUrl 0}}/goto/web/e/pub?action=startreset&pub_id={{$item.pub_id}}&email={{index .ARGS.email_esc 0}}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname_esc 0}}&lastname={{index .ARGS.lastname_esc 0}}

派兹广告平台
