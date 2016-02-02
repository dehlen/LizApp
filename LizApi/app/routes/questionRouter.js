var express = require('express');
var Question   = require('../models/question');
var router = express.Router();
	
router.route('/questions/:categoryId').get(function(req, res) {
	Question.find({categoryId:req.params.categoryId}, function(err, questions) {
		if (err) {
			return res.status(500).json({error:'Could not retrieve questions.'});
		}
		return res.json(questions);
	});
});

router.route('/add/question')
.post(function(req, res) {
	var question = new Question({
		categoryId:req.body.categoryId,
		type:req.body.type,
		text:req.body.text,
		answer:req.body.answer,
		option1:req.body.option1,
		option2:req.body.option2,
		option3:req.body.option3,
		mediaName:req.body.mediaName,
		duration:req.body.duration,
		explanation:req.body.explanation
	});
	
	question.save(function(err, question) {
	  if (err) {
		  return res.status(500).json({error:'Could not save question.'});		  
	  }
	 return res.json(question);
	});
});

router.route('/delete/question')
.delete(function(req, res) {
	Question.remove({ _id: req.body._id }, function(err) {
	    if (!err) {
			return res.status(200).json({msg: "Question deleted."});
		} else {
			return res.status(500).json({error: "Could not delete question."});
	    }
	});
});

router.route('/update/question')
.post(function(req, res) {
  	var id = req.body.question._id;
	 delete req.body.question._id;

	Question.findOneAndUpdate({ _id: id}, req.body.question, function(err, question) {
		if (err) {
			return res.status(500).json({error:"Could not update question."});
		} else {
			return res.status(200).json(question);
		}
	});
});

module.exports = router;