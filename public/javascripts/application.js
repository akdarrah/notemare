jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })

$(document).ready(function() {

  $("#helper").click(function() {
    $("#help").fadeIn('slow');
    return false;
  });
  
  // hide the loader gif image by default
  $("#loader").hide();
  
  // reset errors
  $("#error_msg").hide();
  
  // hide artist_data panel
  $("#artist_data").hide();
  
  // when the search form is submitted, send an ajax request to the server
  // and get the grooveshark code for the artist
  $("form.artist").submit(function() {
    $.post("/artist/songs?artist[name]=" + $("#artist_name").val(), $(this).serialize(), null, "script");
    // disable form input
    $("#artist_submit").hide();
    $("#loader").show();
    return false;
  });

});
