广告商 {{index .ARGS.firstname 0}} {{index .ARGS.lastname 0}}:

你好！

请访问如下地址确认邮箱正确，并完成派兹广告商注册：
{{index .ARGS.serverUrl 0}}/goto/web/g/adv?action=activate&adv_id={{index .ARGS.adv_id 0}}&email={{index .ARGS.email 0|urlquery}}&stamp={{index .ARGS.stamp 0}}&md5={{index .ARGS.md5 0}}&firstname={{index .ARGS.firstname 0|urlquery}}&lastname={{index .ARGS.lastname 0|urlquery}}

派兹网络
