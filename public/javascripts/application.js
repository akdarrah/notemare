
$(document).ready(function() {
  
  // replace + symbols with spaces
  $("#artist_name").attr("value", $("#artist_name").val().replace(/[+]+/,' '));

});
