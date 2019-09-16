{{ define "slotheader" }}
      <!-- Breadcrumb -->
      <ol class="breadcrumb">
        <li class="breadcrumb-item">公司</li>
        <li class="breadcrumb-item"><a href="site?action=topics">媒体</a></li>
        <li class="breadcrumb-item active">广告位</li>
      </ol>
      <div class="container-fluid">
        <div class="animated fadeIn">

                        <section class="row">
                            <div class="col-12">
                                <h3 class="mb-4">媒体{{index .ARGS.site_name 0}}的广告位管理</h3>
                            </div>
                        </section>
{{ end }}
