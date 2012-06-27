$(function() {
  // Auto re-submit form with new url when user clicks a link in response data
  // FIXME: This is stupid and tied to /api/v1…
  $(".tab-content").delegate("a", "click", function() {
    var link = $(this).attr('href');
    var path = link.match(/\/api\/v\d+\/.*/)[0];
    if(path) {
      $('html, body').animate({
        scrollTop: $('form.api').offset().top
      }, 200);
      $('input[name=url]').val(path);
      $('form.api').submit();
      return false;
    }
  });

  $('form.api').submit(function() {
    var button = $(this).find('button').hide();
    $('#spinner').show();

    var paramStr = "";

    $(this).find('input').each(function() {
      var key = $(this).attr('name');
      var value = $(this).val();
      if(key == 'url' || key == 'method') {
        paramStr += key + "=" + encodeURIComponent(value) + "&";
      } else {
        paramStr += "param-keys[]=" + encodeURIComponent(key) + "&";
        paramStr += "param-vals[]=" + encodeURIComponent(value) + "&";
      }
    });

    $('#tab1').empty();
    $('#tab2').empty();
    $.post(ApiBrowser.base_url + '/', paramStr, function(data) {
      $('#spinner').hide();
      button.show();

      var result = data;

      if(result.error) {
        $('#api-error span#error-msg').html(result.error).parent().show();
      } else {
        $('#tab1').html(result.request);
        $('#tab2').html(result.header);
        $('#tab2').append(result.body);
      }
    });

    return false;
  });
});

