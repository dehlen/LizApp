//TODO: edit row, paginate table, load categories on start
$(document).ready(function() {
	
	var latestCategoryId;	
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
						<td class="iconCell"><img src='+config.baseURL+'icons/'+this.iconName+'.png'+' alt="" height="20" width="20"/></td>\
						<td id="'+this.themeColor.substring(1)+'">'+this.themeColor+'</td>\
						<td>'+this.questionLimit+'</td>\
						<td>'+this.leaderboardId+'</td>\
						<td>'+this.productIdentifier+'</td>\
						<td '+onlineClass+'></td>\
						<td><a href="#">Edit</a></td>\
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
	
	loadCategories();
	
	/* Actions */
	$(document).on("click", ".removeCategory", function(e) {
	    e.preventDefault();
		var tableRow = $(this).closest('tr');
		var categoryId = tableRow.children('td:first').text();
		removeCategory(categoryId, function(data, error) {
			if(error) {
				console.log(error);
				showWarningDialog();
			} else {
			    tableRow.remove();
			}
		});
		
		return false;
	});
	
	$('#addCategory').click(function(e) {
		var category = {
			name: $("#categoryNameLabel").val(),
			createdAt: $("#createdAtLabel").val(),
			description: $("#descriptionLabel").val(),
			timeBased: $("#timeBasedCheckbox").is(':checked'),
			iconName: $("#iconSelect option:selected" ).text(),
			themeColor: $("#themeColorPicker").val(),
			questionLimit: $("#questionLimitLabel").val(), 
			leaderboardId: $("#leaderboardIdLabel").val(),
			productIdentifier: $("#productIdentifierLabel").val(),
			online: $("#onlineCheckbox").is(':checked')
		};
				
		addCategory(category, function(data, error) {
			if(error) {
				showWarningDialog();
			} else {						
				var timeBasedClass = (data.timeBased) ? 'class="cell-color-success"' : 'class="cell-color-fail"'; 
				var onlineClass = (data.online) ? 'class="cell-color-success"' : 'class="cell-color-fail"'; 
			    $('#categoryTable tbody').append(
				'<tr>\
					<td>'+data._id+'</td>\
					<td>'+data.name+'</td>\
					<td>'+data.createdAt+'</td>\
					<td>'+data.description+'</td>\
					<td '+timeBasedClass+'></td>\
					<td class="iconCell"><img src='+config.baseURL+'icons/'+data.iconName+'.png'+' alt="" height="20" width="20"/></td>\
					<td id="'+data.themeColor.substring(1)+'">'+data.themeColor+'</td>\
					<td>'+data.questionLimit+'</td>\
					<td>'+data.leaderboardId+'</td>\
					<td>'+data.productIdentifier+'</td>\
					<td '+onlineClass+'></td>\
					<td><a href="#">Edit</a></td>\
					<td><a href="#" class="removeCategory">Delete</a></td>\
					<td><a href="#" class="showQuestions">Questions</a></td>\
				</tr>');
				
				$('#'+data.themeColor.substring(1)).css('background-color', data.themeColor);
				$('#'+data.themeColor.substring(1)).css('color', 'white');
				$('.iconCell').css('background-color', 'gray');
				
			}
		});
		$("#addCategoryDialog").modal("hide");		
	});
	
	$(document).on("click", ".editCategory", function(e) {
	    e.preventDefault();		
		//TODO: make api call, make dialog to fill in the information
		return false;
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