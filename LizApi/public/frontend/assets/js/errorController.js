var showErrorBox = function(id) {
  $(id).show();
  window.setTimeout(function() {
    $(id).hide();
  }, 5000);
}

$(document).on("click", ".close", function(e) {
   $(this).parent().hide();
})
