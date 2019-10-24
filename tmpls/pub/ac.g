{{ define "acheader" }}
      <!-- Breadcrumb -->
      <ol class="breadcrumb">
        <li class="breadcrumb-item">公司</li>{{if .ARGS.site_id}}
        <li class="breadcrumb-item"><a href="site?action=topics">网址</a></li>{{end}}
        <li class="breadcrumb-item active">广告审核</li>
      </ol>
      <div class="container-fluid">
        <div class="animated fadeIn">

                        <section class="row">
                            <div class="col-12">
                                <h3 class="mb-4">审核广告商和广告活动（即黑白名单）{{if .ARGS.site_id}} 网址: {{index .ARGS.site_name 0}}{{end}}</h3>
                            </div>
                        </section>
{{ end }}
