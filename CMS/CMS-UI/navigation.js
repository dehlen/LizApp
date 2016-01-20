//show settings, question,
$(document).ready(function() {	
	$('#showQuestions').click(function(e) {
		e.preventDefault();
		var categoryId = $(this).closest('tr').children('td:first').text();
		//TODO: reload tableview with the correct questions for categoryId
		return false;
	});
	
	$('#showSettings').click(function(e) {
		e.preventDefault();
		//TODO: Navigate to settings page
		return false;
	});
}); 