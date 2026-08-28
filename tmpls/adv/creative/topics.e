{{$active := index .ARGS.active 0}}

<div class="row">
  <div class="col-lg-12">
    <div class="panel panel-primary">
      <div class="panel-heading">Campaign: {{index .ARGS.campaign_name 0}} &nbsp; / &nbsp; Ad Group: {{index .ARGS.item_name 0}}</div>
      <div class="panel-body">
        <div class="table-responsive">
          <table class="table table-striped table-bordered table-hover">
            <thead><tr><th>Creative Name</th><th>Type</th><th>Size</th><th>Rotation Weight</th><th>Creative Source</th><th>Safe Preview</th><th></th></tr></thead>
            <tbody>{{with .Lists}}{{range .}}
              <tr>
                <td>{{.creative_name}}</td>
                <td>{{.media_type}}</td>
                <td>{{.w}} × {{.h}}</td>
                <td>{{.weight}}</td>
                <td><code>{{.content}}</code></td>
                <td>
                  <button class="btn btn-sm btn-warning" data-toggle="modal" data-target="#myModal{{.creative_id}}">View Source Data</button>
                  <div class="modal fade" id="myModal{{.creative_id}}" tabindex="-1" role="dialog" aria-hidden="true">
                    <div class="modal-dialog"><div class="modal-content"><div class="modal-body">
                      <p>This page displays only escaped source data. It does not execute code or request the creative URL.</p>
                      {{if .is_native}}
                      <dl>
                        <dt>Title</dt><dd>{{.native_title}}</dd>
                        <dt>Description</dt><dd>{{.native_description}}</dd>
                        <dt>Call to Action</dt><dd>{{.native_cta}}</dd>
                        <dt>Icon URL</dt><dd>{{.native_icon_url}}</dd>
                        <dt>Main Image URL</dt><dd>{{.native_main_image_url}}</dd>
                      </dl>
                      {{end}}
                      <pre class="creative-source">{{.content}}</pre>
                    </div></div></div>
                  </div>
                </td>
                <td>{{if eq $active "Prepare"}}<a class="btn btn-sm btn-danger" onClick="return (confirm('Delete this creative? This action cannot be undone.')) ? true : false;" href="creative?action=delete&creative_id={{.creative_id}}&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{index $.ARGS.item_id 0}}&item_md5={{index $.ARGS.item_md5 0}}&item_name={{index $.ARGS.item_name 0 | urlquery}}">Delete</a>{{end}}</td>
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
      <div class="panel-heading">Add Creative</div>
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
            <label class="col-sm-2 col-form-label" for="inputCreativeName">Creative Name</label>
            <div class="col-sm-4"><input id="inputCreativeName" type="text" class="form-control" name="creative_name" required></div>
            <label class="col-sm-1 col-form-label" for="inputWeight">Rotation Weight</label>
            <div class="col-sm-2"><input id="inputWeight" type="number" min="0.000001" step="0.000001" class="form-control" name="weight" value="1" required></div>
          </div>

          <div class="form-group row">
            <label class="col-sm-2 col-form-label">Creative Type</label>
            <div class="col-sm-8">
              <label class="radio-inline"><input type="radio" name="media_type" value="Banner" checked> Banner</label>
              <label class="radio-inline"><input type="radio" name="media_type" value="Video"> Video</label>
              <label class="radio-inline"><input type="radio" name="media_type" value="Native"> Native</label>
            </div>
          </div>

          <div class="form-group row">
            <label class="col-sm-2 col-form-label">Size</label>
            <div class="col-sm-2"><input type="number" min="1" max="65535" class="form-control" name="w" placeholder="Width" required></div>
            <div class="col-sm-2"><input type="number" min="1" max="65535" class="form-control" name="h" placeholder="Height" required></div>
          </div>

          <div class="form-group row">
            <label class="col-sm-2 col-form-label" for="inputContent">Banner/Video Creative URL</label>
            <div class="col-sm-8"><input id="inputContent" type="url" name="content" class="form-control" placeholder="https://cdn.example/creative.html or creative.mp4"></div>
          </div>
          <div class="form-group row">
            <label class="col-sm-2 col-form-label" for="inputMedia">Or Upload a Banner Image/Video</label>
            <div class="col-sm-8"><input id="inputMedia" type="file" class="form-control" name="media_1"></div>
          </div>

          <div class="form-group row">
            <label class="col-sm-2 col-form-label">Native Creative Data</label>
            <div class="col-sm-8">
              <p class="help-block">Complete these fields when Native is selected. The system stores structured data; the preview does not load images or execute code.</p>
              <input type="text" class="form-control" name="title" maxlength="50" placeholder="Title (50 characters maximum)">
              <input type="text" class="form-control" name="description" maxlength="255" placeholder="Description (255 characters maximum)">
              <input type="text" class="form-control" name="cta" maxlength="50" placeholder="Call to action (50 characters maximum)">
              <input type="url" class="form-control" name="iconImg" placeholder="Optional: https://cdn.example/icon.png">
              <input type="url" class="form-control" name="mainImg" placeholder="Required: https://cdn.example/main.jpg">
            </div>
          </div>

          <div class="form-group row"><div class="col-sm-2"></div><div class="col-sm-10"><button type="submit" class="btn btn-primary">Save Creative</button></div></div>
        </form>
      </div>
    </div>
  </div>
</div>
{{end}}
