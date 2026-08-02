{{$active := index .ARGS.active 0}}

<div class="row">
  <div class="col-lg-12">
    <div class="panel panel-primary">
      <div class="panel-heading">广告活动：{{index .ARGS.campaign_name 0}} &nbsp; / &nbsp; 广告组：{{index .ARGS.item_name 0}}</div>
      <div class="panel-body">
        <div class="table-responsive">
          <table class="table table-striped table-bordered table-hover">
            <thead><tr><th>素材名</th><th>类型</th><th>尺寸</th><th>轮播权重</th><th>素材源</th><th>安全预览</th><th></th></tr></thead>
            <tbody>{{with .Lists}}{{range .}}
              <tr>
                <td>{{.creative_name}}</td>
                <td>{{.media_type}}</td>
                <td>{{.w}} × {{.h}}</td>
                <td>{{.weight}}</td>
                <td><code>{{.content}}</code></td>
                <td>
                  <button class="btn btn-sm btn-warning" data-toggle="modal" data-target="#myModal{{.creative_id}}">查看源数据</button>
                  <div class="modal fade" id="myModal{{.creative_id}}" tabindex="-1" role="dialog" aria-hidden="true">
                    <div class="modal-dialog"><div class="modal-content"><div class="modal-body">
                      <p>本页只显示转义后的源数据，不执行代码，也不请求素材地址。</p>
                      {{if .is_native}}
                      <dl>
                        <dt>标题</dt><dd>{{.native_title}}</dd>
                        <dt>描述</dt><dd>{{.native_description}}</dd>
                        <dt>行动文案</dt><dd>{{.native_cta}}</dd>
                        <dt>图标地址</dt><dd>{{.native_icon_url}}</dd>
                        <dt>主图地址</dt><dd>{{.native_main_image_url}}</dd>
                      </dl>
                      {{end}}
                      <pre class="creative-source">{{.content}}</pre>
                    </div></div></div>
                  </div>
                </td>
                <td>{{if eq $active "Prepare"}}<a class="btn btn-sm btn-danger" onClick="return (confirm('确认删除此广告素材吗？此操作不可撤销。')) ? true : false;" href="creative?action=delete&creative_id={{.creative_id}}&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{index $.ARGS.item_id 0}}&item_md5={{index $.ARGS.item_md5 0}}&item_name={{index $.ARGS.item_name 0 | urlquery}}">删除</a>{{end}}</td>
              </tr>
            {{end}}{{end}}</tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

{{if eq (index .ARGS.active 0) "Prepare"}}
<div class="row">
  <div class="col-lg-12">
    <div class="panel panel-primary">
      <div class="panel-heading">新增素材</div>
      <div class="panel-body">
        <form name="newcreative" class="form" method="post" action="creative" enctype="multipart/form-data">
          <input type="hidden" name="action" value="insert">
          <input type="hidden" name="campaign_id" value="{{index .ARGS.campaign_id 0}}">
          <input type="hidden" name="campaign_md5" value="{{index .ARGS.campaign_md5 0}}">
          <input type="hidden" name="campaign_name" value="{{index .ARGS.campaign_name 0}}">
          <input type="hidden" name="item_id" value="{{index .ARGS.item_id 0}}">
          <input type="hidden" name="item_md5" value="{{index .ARGS.item_md5 0}}">
          <input type="hidden" name="item_name" value="{{index .ARGS.item_name 0}}">
          <input type="hidden" name="qa_mime" value="{{index .ARGS.qa_mime 0}}">

          <div class="form-group row">
            <label class="col-sm-2 col-form-label" for="inputCreativeName">素材名称</label>
            <div class="col-sm-4"><input id="inputCreativeName" type="text" class="form-control" name="creative_name" required></div>
            <label class="col-sm-1 col-form-label" for="inputWeight">轮播权重</label>
            <div class="col-sm-2"><input id="inputWeight" type="number" min="0.000001" step="0.000001" class="form-control" name="weight" value="1" required></div>
          </div>

          <div class="form-group row">
            <label class="col-sm-2 col-form-label">素材类型</label>
            <div class="col-sm-8">
              <label class="radio-inline"><input type="radio" name="media_type" value="Banner" checked> 横幅</label>
              <label class="radio-inline"><input type="radio" name="media_type" value="Video"> 视频</label>
              <label class="radio-inline"><input type="radio" name="media_type" value="Native"> 原生</label>
            </div>
          </div>

          <div class="form-group row">
            <label class="col-sm-2 col-form-label">尺寸</label>
            <div class="col-sm-2"><input type="number" min="1" max="65535" class="form-control" name="w" placeholder="宽" required></div>
            <div class="col-sm-2"><input type="number" min="1" max="65535" class="form-control" name="h" placeholder="高" required></div>
          </div>

          <div class="form-group row">
            <label class="col-sm-2 col-form-label" for="inputContent">横幅/视频素材地址</label>
            <div class="col-sm-8"><input id="inputContent" type="url" name="content" class="form-control" placeholder="https://cdn.example/creative.html 或 creative.mp4"></div>
          </div>
          <div class="form-group row">
            <label class="col-sm-2 col-form-label" for="inputMedia">或上传横幅图片/视频</label>
            <div class="col-sm-8"><input id="inputMedia" type="file" class="form-control" name="media_1"></div>
          </div>

          <div class="form-group row">
            <label class="col-sm-2 col-form-label">原生素材数据</label>
            <div class="col-sm-8">
              <p class="help-block">选择“原生”时填写。系统保存结构化数据；预览不会加载图片或执行代码。</p>
              <input type="text" class="form-control" name="title" maxlength="50" placeholder="标题（最多 50 字）">
              <input type="text" class="form-control" name="description" maxlength="255" placeholder="描述（最多 255 字）">
              <input type="text" class="form-control" name="cta" maxlength="50" placeholder="行动文案（最多 50 字）">
              <input type="url" class="form-control" name="iconImg" placeholder="可选：https://cdn.example/icon.png">
              <input type="url" class="form-control" name="mainImg" placeholder="必填：https://cdn.example/main.jpg">
            </div>
          </div>

          <div class="form-group row"><div class="col-sm-2"></div><div class="col-sm-10"><button type="submit" class="btn btn-primary">保存素材</button></div></div>
        </form>
      </div>
    </div>
  </div>
</div>
{{end}}
