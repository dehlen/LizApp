var path = require('path');
var fs = require('fs');

exports.save = function(file, handler) {
	if(!file) {
		return handler('placeholder.png');
	}
	var uniqueName = 'file-'+(new Date()).getTime()+path.extname(file.originalname);
	var newPath = path.join(__dirname, '../public/uploads', uniqueName);
	fs.rename(file.path, newPath, function(err) {
                if (err) {
			console.log(err);
			return handler('placeholder.png');
                } else {
			return handler(uniqueName);
		}
        });
}
