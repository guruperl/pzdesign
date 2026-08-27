{{ define "footer" }}
    </div>
  </main>

  <footer class="account-footer">
    <div class="container">
      <p>&copy; 2026 W8M Network Inc.</p>
      <a href="mailto:support@w8m.com">support@w8m.com</a>
    </div>
  </footer>

  <script src="/1.0.8/vendors/js/jquery.min.js"></script>
  <script src="/1.0.8/vendors/js/popper.min.js"></script>
  <script src="/1.0.8/vendors/js/bootstrap.min.js"></script>
  <script src="/1.0.8/js/app.js"></script>
  <script src="/1.0.8/vendors/js/jquery.validate.min.js"></script>
  <script>
  $(function() {
    $('[data-lang-toggle]').on('click', function(e) {
      e.preventDefault();
      var newLang = $(this).attr('data-lang-toggle');
      var path = window.location.pathname;
      // Swap the chartag in the path: /goto/role/g/ -> /goto/role/e/
      var newPath = path.replace(/\/goto\/([^\/]+)\/[ge]\//i, '/goto/$1/' + newLang + '/');
      if (newPath !== path) {
        var destination = newPath + window.location.search + window.location.hash;
        window.location.href = '/language/' + newLang + '?return=' + encodeURIComponent(destination);
      }
    });
  });
  </script>
{{ end }}
