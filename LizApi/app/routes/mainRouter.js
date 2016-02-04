var express = require('express');
var router  = express.Router();
var config  = require('../config');
var fileupload = require('../fileupload');

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
	fileupload.save(req.file, function(filename) {
		return res.json({'filename': filename});
	});
});

module.exports = router;
