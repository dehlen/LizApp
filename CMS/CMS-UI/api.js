var addCategory = function(category, handler){	
	$.ajax({
	    url : config.baseURL+'api/add/category',
	    type : 'POST',
	    data : category,
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

var removeCategory = function(categoryId, handler) {
	$.ajax({
	    url : config.baseURL+'api/delete/category',
	    type : 'POST',
	    data : { "categoryId": categoryId },
	    dataType:'json',
        contentType: "application/json",
		cache : false,
	    success : function(data) {              
	        handler();
	    },
	    error : function(request,error)
	    {
	        handler(error);
	    }
	});
};

var editCategory = function(category) {	
	$.ajax({
	    url : config.baseURL+'api/update/category',
	    type : 'POST',
	    data : category,
	    dataType:'json',
        contentType: "application/json",
		cache : false,
	    success : function(data) {              
	        handler();
	    },
	    error : function(request,error)
	    {
	        handler(error);
	    }
	});
};