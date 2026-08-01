{{ $item := index .Lists 0 }}
您好，{{$item.lastname}}{{$item.firstname}}：

我们收到了 W8M 广告主账户的密码重置请求。请使用以下链接设置新密码：
{{index .ARGS.serverUrl 0}}/goto/web/g/adv?action=startreset&adv_id={{$item.adv_id}}&email={{index .ARGS.email 0|urlquery}}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0|urlquery}}&lastname={{index .ARGS.lastname 0|urlquery}}

如果这不是您的操作，可以忽略这封邮件。

W8M 广告平台
