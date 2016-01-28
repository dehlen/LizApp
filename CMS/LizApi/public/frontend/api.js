var loadAllCategories = function(handler) {
	$.ajax({
	    url : config.baseURL+'api/categories',
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

var addCategory = function(category, handler) {
	$.ajax({
	    url : config.baseURL+'api/add/category',
	    type : 'POST',
	    data : JSON.stringify(category),
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

var removeCategory = function(id, handler) {
	$.ajax({
	    url : config.baseURL+'api/delete/category',
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

var editCategory = function(category, handler) {
	var json = {"category": category};	
	$.ajax({
	    url : config.baseURL+'api/update/category',
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
