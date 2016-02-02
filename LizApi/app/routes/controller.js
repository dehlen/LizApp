var express = require('express');
var fs      = require('fs');
var path    = require('path');
var router  = express.Router();

router.use(require('../logger').logger);
router.use('/api', require('./categoryRouter'))
router.use('/api', require('./questionRouter'))

router.route('/').get(function(req, res) {
  res.render('index');
});

router.route('/questions/:categoryId').get(function(req, res) {
  res.render('question', { categoryId: req.params.categoryId});
});

router.route('/upload').post(function(req, res) {
	if (!req.file) {
		return res.status(404).json({error: 'No file information was found.'});
	}
	var uniqueName = 'file-'+(new Date()).getTime()+path.extname(req.file.originalname);
	var newPath = path.join(__dirname, 'public/uploads', uniqueName);
	fs.rename(req.file.path, newPath, function(err) {
		if (err) {
			return res.status(500).json({error: 'Could not rename file.'});
		}
	});
	return res.json({'filename': uniqueName});
});

module.exports = router;
