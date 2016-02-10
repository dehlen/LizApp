$(document).ready(function() {

  $('#postQuestionButton').click(function(event) {
    event.preventDefault();
    //TODO: validate on server if combination makes sense (type and media)
    //TODO: not necesarrily upload a file
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
            //TODO: Show error to user
          });
      },
      error: function(request, error) {
        //TODO: Show error to user
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
      error: function(request, error) {
        //TODO: Show error to user
      }
    });
    return false;
  });
});
