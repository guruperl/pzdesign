{{ template "header" .}}
{{ template "pubheader" .}}

{{$item := index .Lists 0}}

          <div class="card">
            <div class="card-header">
              账户资料
            </div>
            <div class="card-body">
<h4>账户资料已更新。</h4>
            </div>
          </div>

{{ template "footer" }}

</body>
</html>
