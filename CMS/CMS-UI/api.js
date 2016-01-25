var loadAllCategories = function(handler) {
	$.ajax({
	    url : config.baseURL+'api/categories',
	    type : 'GET',
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

var removeCategory = function(categoryId, handler) {
	var catData = {"categoryId": categoryId};
	console.log(catData);
	$.ajax({
	    url : config.baseURL+'api/delete/category',
	    type : 'DELETE',
	    data : JSON.stringify(catData),
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