$(document).ready(function() {

  $('#postQuestionButton').click(function(event) {
    event.preventDefault();

    var formData = new FormData();
    formData.append('file', $('#questionFileInput')[0].files[0]);

    $.ajax({
      url: currentBaseurl + config.router.web.upload,
      type: 'POST',
      data: formData,
      dataType: 'json',
      cache: false,
      processData: false,
      contentType: false,
      success: function(data) {
        $.post(currentBaseurl + '' + config.router.question.post,
        $('#addQuestionForm').serialize() + '&mediaName=' + data.filename + '&categoryId='+categoryId , function(data, status, xhr) {
            $("#addQuestionDialog").modal('hide');
          })
          .done(function() {
            setTimeout(function() {
              window.location.reload(false);
            }, 500);
          })
          .fail(function() {
            showErrorBox("#questionDialogErrorBox");
          });
      },
      error: function(request, error) {
        showErrorBox("#questionDialogErrorBox");
      }

    });
  });

  $(document).on("click", ".removeQuestion", function(e) {
    e.preventDefault();
    var tableRow = $(this).closest('tr');
    var _id = tableRow.children('td:first').text();
    var payload = {
      "_id": _id
    };
    $.ajax({
      url: currentBaseurl + config.router.question.delete,
      type: 'DELETE',
      data: JSON.stringify(payload),
      dataType: 'json',
      contentType: "application/json",
      cache: false,
      success: function(data) {
        tableRow.remove();
      },
      error: function() {
        showErrorBox("#questionErrorBox");
      }
    });
    return false;
  });

  $('#questionType').on('change', function() {
    $("#questionFileInput").prop('disabled', false);
    $("#option2Text").prop('disabled', false);
    $("#option3Text").prop('disabled', false);
    document.getElementById("questionFileInput").accept = "audio/*,image/*,video/mp4,video/x-m4v,video/*";

    switch(this.value) {
      case "text":
        $("#questionFileInput").prop('disabled', true);
      break;
      case "truefalse":
        $("#option2Text").prop('disabled', true);
        $("#option3Text").prop('disabled', true);
      break;
      case "audio":
        document.getElementById("questionFileInput").accept = "audio/*";
      break;
      case "video":
        document.getElementById("questionFileInput").accept = "video/mp4,video/x-m4v,video/*";
      break;
      case "picture":
        document.getElementById("questionFileInput").accept = "image/*";
      break;
      default:
        throw new RuntimeException("unreachable");
    }
  });
});
