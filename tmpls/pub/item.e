{{ define "itemheader" }}
      <!-- Breadcrumb -->
      <ol class="breadcrumb">
        <li class="breadcrumb-item">Publisher Account</li>{{if .ARGS.site_id}}
        <li class="breadcrumb-item"><a href="site?action=topics">Traffic Sources</a></li>{{end}}
        <li class="breadcrumb-item active">Ad Group Review</li>
      </ol>
      <div class="container-fluid">
        <div class="animated fadeIn">

                        <section class="row">
                            <div class="col-12">
                                <h3 class="mb-4">Campaign: {{index .ARGS.campaign_name 0}}</h3>
                            </div>
                        </section>
{{ end }}
