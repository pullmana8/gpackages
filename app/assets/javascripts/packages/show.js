$(function() {
  var atom = $('#package-title').data('atom');

  $.ajax({
    url: '/packages/' + atom + '/changelog'
  }).done(function(data) {
    $('#changelog-container').html(data);
    $(document).trigger('kkuleomi:ajax');
  }).fail(function() {
    $('#changelog-container > li').html('<span class="fa fa-fw fa-3x fa-ban text-danger"></span><br><br>Changelog currently not available. Please check back later.');
  });

  $('#kk-keyword-legend-btn').popover({
    content: function(btn) {
      return $('#kk-keyword-legend-text').html();
    },
    html: true,
    trigger: 'toggle'
  });

  $('#kk-keyword-legend-btn').click(function() {
    return false;
  });
});
