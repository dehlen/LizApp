var loadAllQuestions = function(handler) {
	$.ajax({
	    url : config.baseURL+'api/questions',
	    type : 'GET',
		cache : false,
	    success : function(data) {              
	        handler(data);
	    },
	    error : function(request,error)
	    {
	        handler(null, error);
	    }
	});
};

var addQuestion = function(question, handler) {
	$.ajax({
	    url : config.baseURL+'api/add/question',
	    type : 'POST',
	    data : JSON.stringify(question),
	    dataType:'json',
        contentType: "application/json",
		cache : false,
	    success : function(data) {              
	        handler(data);
	    },
	    error : function(request,error)
	    {
	        handler(null, error);
	    }
	});
};

var removeQuestion = function(id, handler) {
	$.ajax({
	    url : config.baseURL+'api/delete/question',
	    type : 'DELETE',
	    data : JSON.stringify(id),
	    dataType:'json',
        contentType: "application/json",
		cache : false,
	    success : function(data) {              
	        handler(data);
	    },
	    error : function(request,error)
	    {
	        handler(null, error);
	    }
	});
};

var editQuestion = function(question, handler) {
	var json = {"question": question};	
	$.ajax({
	    url : config.baseURL+'api/update/question',
	    type : 'POST',
	    data : JSON.stringify(json),
	    dataType:'json',
        contentType: "application/json",
		cache : false,
	    success : function(data) {              
	        handler(data);
	    },
	    error : function(request,error)
	    {
	        handler(null, error);
	    }
	});
};

var uploadFile = function(fileInputId, handler) {
var formData = new FormData();
formData.append('file', $('#'+fileInputId)[0].files[0]);   
$.ajax({
       url : config.baseURL+'api/upload',
       type : 'POST',
       data : formData,
       dataType : 'json',
       cache : false,
       processData: false,  
       contentType: false,
       success : function(data) {
           handler(data);
       },
       error : function(request, error) {
	handler(null, error);
	}	
});
};
