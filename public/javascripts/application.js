jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })

$(document).ready(function() {
  
  // hide the loader gif image by default
  $("#loader").hide();
  
  // hide artist_data panel
  $("#artist_data").hide();
  
  // when the search form is submitted, send an ajax request to the server
  // and get the grooveshark code for the artist
  $("form.artist").submit(function() {
    $.post("/artist/songs?artist[name]=" + $("#artist_name").val(), $(this).serialize(), null, "script");
    // disable form input
    $("#artist_submit").hide();
    $("#loader").show();
    $("#artist_name").attr("disabled", true);
    return false;
  });

});
