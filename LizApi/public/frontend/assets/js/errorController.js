var showErrorBox = function() {
  $(".alert").show();
  window.setTimeout(function() {
    $(".alert").hide();
  }, 5000);
}

$(document).on("click", ".close", function(e) {
  $('.alert').hide();
})
