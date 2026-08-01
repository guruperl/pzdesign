您好，{{index .ARGS.lastname 0}}{{index .ARGS.firstname 0}}：

您正在注册 W8M 流量方（发布商）账户。请使用以下链接验证注册邮箱并完成账户注册：
{{index .ARGS.serverUrl 0}}/goto/web/g/pub?action=activate&pub_id={{index .ARGS.pub_id 0}}&email={{index .ARGS.email 0 | urlquery }}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0 | urlquery }}&lastname={{index .ARGS.lastname 0 | urlquery }}

如果这不是您的操作，可以忽略这封邮件。

W8M 广告平台
