//TODO: paginate table
$(document).ready(function() {
	
	var currentEditedRow;

	$('.colorpicker').colorpicker();
		 
	var loadCategories = function() {
		loadAllCategories(function(data, error) {
			if(error) {
				showWarningDialog();
			} else {
				jQuery.each(data, function() {
					var timeBasedClass = (this.timeBased) ? 'class="cell-color-success"' : 'class="cell-color-fail"'; 
					var onlineClass = (this.online) ? 'class="cell-color-success"' : 'class="cell-color-fail"'; 
					
				    $('#categoryTable tbody').append(
					'<tr>\
						<td>'+this._id+'</td>\
						<td>'+this.name+'</td>\
						<td>'+this.createdAt+'</td>\
						<td>'+this.description+'</td>\
						<td '+timeBasedClass+'></td>\
						<td class="iconCell"><img src='+config.baseURL+'uploads/'+this.iconName+' alt="" height="20" width="20"/></td>\
						<td id="'+this.themeColor.substring(1)+'">'+this.themeColor+'</td>\
						<td>'+this.questionLimit+'</td>\
						<td>'+this.leaderboardId+'</td>\
						<td>'+this.productIdentifier+'</td>\
						<td '+onlineClass+'></td>\
						<td><a href="#" class="editCategory">Edit</a></td>\
						<td><a href="#" class="removeCategory">Delete</a></td>\
						<td><a href="#" class="showQuestions">Questions</a></td>\
					</tr>');
				
					$('#'+this.themeColor.substring(1)).css('background-color', this.themeColor);
					$('#'+this.themeColor.substring(1)).css('color', 'white');
					$('.iconCell').css('background-color', 'gray');
				});						
			}
		});
	}
	//Load Categories on start
	loadCategories();
	
	/* Actions */
	$(document).on("click", ".removeCategory", function(e) {
	    e.preventDefault();
		var tableRow = $(this).closest('tr');
		var _id = tableRow.children('td:first').text();
		var idJSON = {"_id": _id};

		removeCategory(idJSON, function(data, error) {
			if(error) {
				showWarningDialog();
			} else {
			    tableRow.remove();
			}
		});
		return false;
	});
	                             
	$('#addCategory').click(function(e) {
		//Selectors from add dialog
		var category = {
			name: $("#categoryNameLabel").val(),
			createdAt: $("#createdAtLabel").val(),
			description: $("#descriptionLabel").val(),
			timeBased: $("#timeBasedCheckbox").is(':checked'),
			themeColor: $("#themeColorPicker").val(),
			questionLimit: $("#questionLimitLabel").val(), 
			leaderboardId: $("#leaderboardIdLabel").val(),
			productIdentifier: $("#productIdentifierLabel").val(),
			online: $("#onlineCheckbox").is(':checked')
		};

		uploadFile('fileInput', function(data, error) {
			if (error) {
				showWarningDialog();
			}
			else {
				category.iconName = data.filename;
				addCategory(category, function(data, error) {
                        if(error) {
                                showWarningDialog();
                        } else {
                                var timeBasedClass = (data.timeBased) ? 'class="cell-color-success"' : 'class="cell-color-fail';
                                var onlineClass = (data.online) ? 'class="cell-color-success"' : 'class="cell-color-fail';
                    
				$('#categoryTable tbody').append(
                                '<tr>\
                                      	<td>'+data._id+'</td>\
                                        <td>'+data.name+'</td>\
                                        <td>'+data.createdAt+'</td>\
                                        <td>'+data.description+'</td>\
                                        <td '+timeBasedClass+'></td>\
                                        <td class="iconCell"><img src="'+config.baseURL+'uploads/'+data.iconName+'"'+' alt="" height="20" width="20"/></td>\
                                        <td id="'+data.themeColor.substring(1)+'">'+data.themeColor+'</td>\
                                        <td>'+data.questionLimit+'</td>\
                                        <td>'+data.leaderboardId+'</td>\
                                        <td>'+data.productIdentifier+'</td>\
                                        <td '+onlineClass+'></td>\
                                        <td><a href="#" class="editCategory">Edit</a></td>\
                                        <td><a href="#" class="removeCategory">Delete</a></td>\
                                        <td><a href="#" class="showQuestions">Questions</a></td>\
                                </tr>');

                                $('#'+data.themeColor.substring(1)).css('background-color', data.themeColor);
                                $('#'+data.themeColor.substring(1)).css('color', 'white');
                                $('.iconCell').css('background-color', 'gray');
                        }
                });
			}		
		});
		
		$("#addCategoryDialog").modal("hide");		
	});
	
	$(document).on("click", ".editCategory", function(e) {
	    e.preventDefault();
		currentEditedRow = $(this).closest("tr");
		var old = {
			_id: currentEditedRow.find("td:nth-child(1)").text(),
			name:currentEditedRow.find("td:nth-child(2)").text(),
			createdAt:currentEditedRow.find("td:nth-child(3)").text(),
			description:currentEditedRow.find("td:nth-child(4)").text(),
			timeBased:currentEditedRow.find("td:nth-child(5)").hasClass("cell-color-success") ? true : false,
			themeColor:currentEditedRow.find("td:nth-child(7)").text(),
			questionLimit:Number(currentEditedRow.find("td:nth-child(8)").text()), 
			leaderboardId: currentEditedRow.find("td:nth-child(9)").text(),
			productIdentifier:currentEditedRow.find("td:nth-child(10)").text(),
			online: currentEditedRow.find("td:nth-child(11)").hasClass("cell-color-success") ? true : false
		};
		
		$("#categoryIdLabel2").val(old._id);
		$("#categoryNameLabel2").val(old.name);
		$("#createdAtLabel2").val(old.createdAt);
		$("#descriptionLabel2").val(old.description);
		$("#timeBasedCheckbox2").prop('checked', old.timeBased);
		$("#themeColorPicker2").val(old.themeColor);
		$("#questionLimitLabel2").val(old.questionLimit); 
		$("#leaderboardIdLabel2").val(old.leaderboardId);
		$("#productIdentifierLabel2").val(old.productIdentifier);
		$("#onlineCheckbox2").prop('checked', old.online);
	
		$('.updateableColorPicker').colorpicker('setValue', old.themeColor);
		$('#editCategoryDialog').modal('show');
		return false;
	});
	
	$("#editCategory").click(function(e) {
		//Selectors from editDialog
		$("input").blur();
		var category = {
			_id : $("#categoryIdLabel2").val(),
			name: $("#categoryNameLabel2").val(),
			createdAt: $("#createdAtLabel2").val(),
			description: $("#descriptionLabel2").val(),
			timeBased: $("#timeBasedCheckbox2").is(':checked'),
			themeColor: $("#themeColorPicker2").val(),
			questionLimit: Number($("#questionLimitLabel2").val()), 
			leaderboardId: $("#leaderboardIdLabel2").val(),
			productIdentifier: $("#productIdentifierLabel2").val(),
			online: $("#onlineCheckbox2").is(':checked')
		};
		 uploadFile('fileInput2', function(data, error) {
                        if (error) {
                                showWarningDialog();
                        }
                        else {
			category.iconName = data.filename;
				editCategory(category, function(data, error) {
					if(error) {
						showWarningDialog();
					} else {
				var timeBasedClass = (data.timeBased) ? 'class="cell-color-success"' : 'class="cell-color-fail"'; 
				var onlineClass = (data.online) ? 'class="cell-color-success"' : 'class="cell-color-fail"'; 
			    
				var newTableRow = '<td>'+data._id+'</td>';
				newTableRow += '<td>'+data.name+'</td>';
				newTableRow += '<td>'+data.createdAt+'</td>';
				newTableRow += '<td>'+data.description+'</td>';
				newTableRow += '<td '+timeBasedClass+'></td>';
				newTableRow += '<td class="iconCell"><img src="'+config.baseURL+'uploads/'+data.iconName+'"'+' alt="" height="20" width="20"/></td>';
				newTableRow += '<td id="'+data.themeColor.substring(1)+'">'+data.themeColor+'</td>';
				newTableRow += '<td>'+data.questionLimit+'</td>';
				newTableRow += '<td>'+data.leaderboardId+'</td>';
				newTableRow += '<td>'+data.productIdentifier+'</td>';
				newTableRow += '<td '+onlineClass+'></td>';
				newTableRow += '<td><a href="#" class="editCategory">Edit</a></td>';
				newTableRow += '<td><a href="#" class="removeCategory">Delete</a></td>';
				newTableRow += '<td><a href="#" class="showQuestions">Questions</a></td>';
				
				currentEditedRow.html(newTableRow);
				
				$('#'+data.themeColor.substring(1)).css('background-color', data.themeColor);
				$('#'+data.themeColor.substring(1)).css('color', 'white');
				$('.iconCell').css('background-color', 'gray');
			}
		});
		}
});
		$('#editCategoryDialog').modal('hide');
	});
	
	$('#tableSearchBar').keyup(function () {
		var rex = new RegExp($(this).val(), 'i');
		$('.searchable tr').hide();
		$('.searchable tr').filter(function () {
			return rex.test($(this).text());
		}).show();
	});
	
	var showWarningDialog = function() {
		$("#warningDialog").fadeIn(600,function() {
			$("#warningDialog").delay(8000).fadeOut(600);
		});
	};
}); 
