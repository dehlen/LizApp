var express = require('express');
var fs      = require('fs');
var path    = require('path');
var router  = express.Router();
var config  = require('../config');

var categoryRouter = require('./categoryRouter');
var questionRouter = require('./questionRouter');

router.use(require('../logger').logger);
router.use('/api', categoryRouter);
router.use('/api', questionRouter);
router.use('/game', require('./gameLogicRouter'));

router.route('/').get(function(req, res) {
	categoryRouter.loadCategories(function(categories, err) {
		 if (err) {
                        return res.status(500).json({error:'Could not retrieve categories.'});
                }

                return res.render('categories', {categories: categories , baseurl:config.server.baseurl.prod});
	});
});

router.route('/questions/:categoryId').get(function(req, res) {
 	questionRouter.loadQuestions(req.params.categoryId, function(questions, err) {
                 if (err) {
                        return res.status(500).json({error:'Could not retrieve questions.'});
                }
                return res.render('questions', {questions: questions , baseurl:config.server.baseurl.prod, categoryId:req.params.categoryId});
        }); 	
});

router.route('/upload').post(function(req, res) {
	if (!req.file) {
		return res.status(404).json({error: 'No file information was found.'});
	}
	var uniqueName = 'file-'+(new Date()).getTime()+path.extname(req.file.originalname);
	var newPath = path.join(__dirname, '../../public/uploads', uniqueName);
	fs.rename(req.file.path, newPath, function(err) {
		if (err) {
			console.log(err);
			return res.status(500).json({error: 'Could not rename file.'});
		}
	});
	return res.json({'filename': uniqueName});
});

module.exports = router;
