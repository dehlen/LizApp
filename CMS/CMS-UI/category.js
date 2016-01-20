//TODO: edit row, paginate table
$(document).ready(function() {
	/* Setup for custom components */
	var latestCategoryId;
	
	$('.colorpicker').colorpicker();
	$("#iconSelect").fileinput({
		previewFileType: "image",
		showUpload: true,
		uploadUrl: config.baseURL+"api/upload",
		uploadAsync: false,
		browseClass: "btn btn-success",
		browseLabel: "Pick Icon",
		browseIcon: "<i class=\"glyphicon glyphicon-picture\"></i> ",
		removeClass: "btn btn-danger",
		removeLabel: "Delete",
		removeIcon: "<i class=\"glyphicon glyphicon-trash\"></i> ",
		uploadExtraData: function() {
			var fileInfo = {"name": latestCategoryId};
			return fileInfo;
		}
	});
	
	/* Actions */	
	$('#removeCategory').click(function(e) {
	    e.preventDefault();
		var tableRow = $(this).closest('tr');
		var categoryId = tableRow.children('td:first').text();
		
		removeCategory(categoryId, function(error) {
			if(error) {
				showWarningDialog();
			} else {
			    tableRow.remove();
			}
		});
		
		return false;
	});
	
	$('#addCategory').click(function(e) {
		/* TODO:  
		in api: 
			nodejs api erhält bild unter /api/upload route unter dem parameter file_data und unter fileInfo.name 
			die categoryId die als name für den file dienen soll beim abspeichern
			categoryId erstellen und daten zurückliefern in nodejs api
			falls successfull daten in tabelle eintragen
		*/		
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
		
		addCategory(category, function(data, error) {
			if(error) {
				showWarningDialog();
			} else {
				if (data.categoryId) {
					latestCategoryId = data.categoryId;
					$('#iconSelect').fileinput('upload');
				}
				var timeBasedClass = (data.timeBased) ? 'class="cell-color-success"' : 'class="cell-color-fail"'; 
				var onlineClass = (data.online) ? 'class="cell-color-success"' : 'class="cell-color-fail"'; 
				
			    $('#categoryTable tbody').append(
				'<tr>\
					<td>'+data.id+'</td>\
					<td>'+data.name+'</td>\
					<td>'+data.createdAt+'</td>\
					<td>'+data.description+'</td>\
					<td'+timeBasedClass+'></td>\
					<td><img src='+data.iconUrl+' alt="" height="20" width="20"/></td>\
					<td id="themeColorCell">'+data.themeColor+'</td>\
					<td>'+data.questionLimit+'</td>\
					<td>'+data.leaderboardId+'</td>\
					<td>'+data.productIdentifier+'</td>\
					<td'+onlineClass+'></td>\
				</tr>');
				
				$('#themeColorCell').css('background-color', data.themeColor);
				$('#themeColorCell').css('color', 'white');
			}
		});		
	});
	
	$('#editCategory').click(function(e) {
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