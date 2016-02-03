var express = require('express');
var router = express.Router();
var Category = require('../models/category');
var Question = require('../models/question');	

router.route('/questions/:categoryId').get(function(req, res) {
	Category.findOne({_id: req.params.categoryId}, function(err, category) {   
		if(err || !category) {
			return res.status(500).json({error: "Could not find category for this id."});
		} else {
			Question.findRandom({categoryId: req.params.categoryId}, {}, {limit: category.questionLimit}, function(err, questions) {
                		if (err) {
					console.log(err);
                        		return res.status(500).json({error: "Could not find random questions for this category."});
                		} else {
					return res.json(questions);
				}
        		});
		}
	})
});

module.exports = router;

