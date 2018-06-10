商户 {{index .ARGS.lastname 0}}{{index .ARGS.firstname 0}}:

您好！

请点击如下链接完成派兹媒体商户注册:
{{index .ARGS.serverUrl 0}}/goto/web/g/pub?action=activate&pub_id={{index .ARGS.pub_id 0}}&email={{index .ARGS.email 0 | urlquery }}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0 | urlquery }}&lastname={{index .ARGS.lastname 0 | urlquery }}

派兹广告平台
