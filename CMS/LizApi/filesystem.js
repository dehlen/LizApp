var fs = require('fs');

storeCategoryIcon = function(data, imageName) {	
	var newPath = __dirname + "/uploads/fullsize/" + imageName;
	
	fs.writeFile(newPath, data, function (err) {
		if (err) throw err;
		return newPath;
	});
};