jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })

$(document).ready(function() {
  
  // replace + symbols with spaces in search field
  $("#artist_name").attr("value", $("#artist_name").val().replace(/[+]+/,' '));

  // when the search form is submitted, send an ajax request to the server
  // and get the grooveshark code for the artist
  $("form.artist").submit(function() {
    $.post("/start/songs?artist[name]=" + $("#artist_name").val(), $(this).serialize(), null, "script")
    return false;
  });

});
