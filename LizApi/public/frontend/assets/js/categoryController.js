$(document).ready(function() {
	var themeCells = function() {
    	var tableCells = document.getElementsByClassName('themeable');
    	for(var i=0;i<tableCells.length;i++) {
        	tableCells[i].style.backgroundColor = tableCells[i].innerText;
        	tableCells[i].style.color = 'white';
    	}
	}
	
	themeCells();

	$('#postCategoryButton').click(function(event) {
		event.preventDefault();
		var formData = new FormData();
		formData.append('file', $('#fileInput')[0].files[0]);
		$.ajax({
		       url : config.router.baseurl.prod+config.router.web.upload,
		       type : 'POST',
		       data : formData,
		       dataType : 'json',
		       cache : false,
		       processData: false,
		       contentType: false,
		       success : function(data) {
				console.log(data.filename);
    				$.post(config.router.baseurl.prod+''+config.router.category.post, $('#addCategoryForm').serialize()+'&iconName='+data.filename, function(data, status, xhr) {
       					//TODO: Update website by refreshing for example
    				})
    				.done(function() {
        				setTimeout(function(){
           					$("#addCategoryDialog").modal('hide');
        				}, 1000);
    				})
    				.fail(function() {
        				//TODO: show user error
    				});
		       },
		       error : function(request, error) {
			   //TODO: Show error
		       }
			   
		});
    	});

	 $(document).on("click", ".removeCategory", function(e) {
        	e.preventDefault();
                var tableRow = $(this).closest('tr');
		var _id = tableRow.children('td:first').text();
                var payload = {"_id": _id};
		$.ajax({
           		url : config.router.baseurl.prod+config.router.category.delete,
            	 	type : 'DELETE',
            		data : JSON.stringify(payload),
            		dataType:'json',
        	 	contentType: "application/json",
                 	cache : false,
            	 	success : function(data) {
				tableRow.remove();
            		},
            		error : function(request,error) {
				//TODO: Show error to user
            		}
		});
                return false;
        });

	$(document).on("click", ".showQuestions", function(e) {
            	e.preventDefault();
                var tableRow = $(this).closest('tr');
                var _id = tableRow.children('td:first').text();
                window.location.href='/questions/'+_id;
                return false;
        });
});

