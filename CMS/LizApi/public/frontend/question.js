//TODO: paginate table
$(document).ready(function() {
	
	var loadQuestions = function() {
		loadAllQuestions(function(data, error) {
			if(error) {
				showWarningDialog();
			} else {
				jQuery.each(data, function() {
				    $('#questionTable tbody').append(
					'<tr>\
						<td>'+this._id+'</td>\
						<td>'+this.type+'</td>\
						<td>'+this.text+'</td>\
						<td>'+this.answer+'</td>\
						<td>'+this.option1+'</td>\
						<td>'+this.option2+'</td>\
						<td>'+this.option3+'</td>\
						<td class="mediaCell"><img src='+config.baseURL+'uploads/'+this.mediaName+' alt="" height="20" width="20"/></td>\
						<td>'+this.duration+'</td>\
						<td>'+this.explanation+'</td>\
						<td><a href="#" class="editQuestion">Edit</a></td>\
						<td><a href="#" class="removeQuestion">Delete</a></td>\
					</tr>');
				});						
			}
		});
	}
	//Load questions on start
	loadQuestions();
	
	$('#questionType').on('change', function (e) {
	    var valueSelected = this.value;
    	$("#option2Text").prop('disabled', false);
		$("#option3Text").prop('disabled', false);
		
	    if (valueSelected == "text") {
	    	$("#questionFileInput").prop('disabled', true);
	    } else if (valueSelected == "picture") {
	    	$("#questionFileInput").prop('disabled', false);
	    	document.getElementById("questionFileInput").accept = "image/*";
	    } else if (valueSelected == "video") {
	    	$("#questionFileInput").prop('disabled', false);
	    	document.getElementById("questionFileInput").accept = "video/*";
	    } else if (valueSelected == "audio") {
	    	$("#questionFileInput").prop('disabled', false);
	    	document.getElementById("questionFileInput").accept = "audio/*";
	    } else if (valueSelected == "truefalse") {
	    	$("#option2Text").prop('disabled', true);
			$("#option3Text").prop('disabled', true);
	    	$("#questionFileInput").prop('disabled', true);
	    }
	});
	
	$('#addQuestion').click(function(e) {
		var question = {
			type: $("#questionType").val(),
			text: $("#questionText").val(),
			answer: $("#answerText").val(),
			option1: $("#option1Text").val(),
			option2: $("#option2Text").val(),
			option3: $("#option3Text").val(),
			duration: $("#durationSpinner").val(), 
			explanation: $("#explanationText").val()
		};
		
		if (question.type == "text" || question.type == "truefalse") {
			question.mediaName = '';
			addQuestion(question, function(data, error) {
                    if(error) {
                            showWarningDialog();
                    } else {
					    $('#questionTable tbody').append(
						'<tr>\
							<td>'+data._id+'</td>\
							<td>'+data.type+'</td>\
							<td>'+data.text+'</td>\
							<td>'+data.answer+'</td>\
							<td>'+data.option1+'</td>\
							<td>'+data.option2+'</td>\
							<td>'+data.option3+'</td>\
							<td class="mediaCell">None</td>\
							<td>'+data.duration+'</td>\
							<td>'+data.explanation+'</td>\
							<td><a href="#" class="editQuestion">Edit</a></td>\
							<td><a href="#" class="removeQuestion">Delete</a></td>\
						</tr>'); 
                    }
            });
		} else {
			uploadFile('questionFileInput', function(data, error) {
				if (error) {
					showWarningDialog();
				}
				else {
					question.mediaName = data.filename;
					addQuestion(question, function(data, error) {
	                        if(error) {
	                                showWarningDialog();
	                        } else {
							    $('#questionTable tbody').append(
								'<tr>\
									<td>'+data._id+'</td>\
									<td>'+data.type+'</td>\
									<td>'+data.text+'</td>\
									<td>'+data.answer+'</td>\
									<td>'+data.option1+'</td>\
									<td>'+data.option2+'</td>\
									<td>'+data.option3+'</td>\
									<td class="mediaCell"><img src='+config.baseURL+'uploads/'+data.mediaName+' alt="" height="20" width="20"/></td>\
									<td>'+data.duration+'</td>\
									<td>'+data.explanation+'</td>\
									<td><a href="#" class="editQuestion">Edit</a></td>\
									<td><a href="#" class="removeQuestion">Delete</a></td>\
								</tr>'); 
	                        }
	                });
				}		
			});
		}
		
		$("#addCategoryDialog").modal("hide");		
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
