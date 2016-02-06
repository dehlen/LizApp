var loadAllQuestions = function(categoryId, handler) {
  $.ajax({
    url: config.baseURL + 'api/questions/' + categoryId,
    type: 'GET',
    cache: false,
    success: function(data) {
      handler(data);
    },
    error: function(request, error) {
      handler(null, error);
    }
  });
};

var addQuestion = function(question, handler) {
  $.ajax({
    url: config.baseURL + 'api/questions',
    type: 'POST',
    data: JSON.stringify(question),
    dataType: 'json',
    contentType: "application/json",
    cache: false,
    success: function(data) {
      handler(data);
    },
    error: function(request, error) {
      handler(null, error);
    }
  });
};

var removeQuestion = function(id, handler) {
  $.ajax({
    url: config.baseURL + 'api/questions',
    type: 'DELETE',
    data: JSON.stringify(id),
    dataType: 'json',
    contentType: "application/json",
    cache: false,
    success: function(data) {
      handler(data);
    },
    error: function(request, error) {
      handler(null, error);
    }
  });
};

var editQuestion = function(question, handler) {
  var json = {
    "question": question
  };
  $.ajax({
    url: config.baseURL + 'api/questions',
    type: 'PUT',
    data: JSON.stringify(json),
    dataType: 'json',
    contentType: "application/json",
    cache: false,
    success: function(data) {
      handler(data);
    },
    error: function(request, error) {
      handler(null, error);
    }
  });
};

var uploadFile = function(fileInputId, handler) {
  var formData = new FormData();
  formData.append('file', $('#' + fileInputId)[0].files[0]);
  $.ajax({
    url: config.baseURL + 'upload',
    type: 'POST',
    data: formData,
    dataType: 'json',
    cache: false,
    processData: false,
    contentType: false,
    success: function(data) {
      handler(data);
    },
    error: function(request, error) {
      handler(null, error);
    }
  });
};
