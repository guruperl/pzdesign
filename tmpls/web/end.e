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
    $('[data-chartag-toggle]').on('click', function(e) {
      e.preventDefault();
      var newChartag = $(this).attr('data-chartag-toggle');
      if (newChartag !== 'g' && newChartag !== 'e') {
        return;
      }
      var path = window.location.pathname;
      // Swap only the public web chartag: /goto/web/g/ -> /goto/web/e/.
      var newPath = path.replace(/^\/goto\/web\/[ge]\//i, '/goto/web/' + newChartag + '/');
      if (newPath !== path) {
        var destination = newPath + window.location.search + window.location.hash;
        window.location.href = destination;
      }
    });
  });
  </script>
{{ end }}
