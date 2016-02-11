var express = require('express');
var router = express.Router();
var Question = require('../models/question');
var mime = require('mime');

var isValidQuestion = function(question) {
  if(question.type == 'audio') {
    return mime.lookup(question.mediaName).substring(0,5) === 'audio';
  } else if (question.type == 'video') {
    return mime.lookup(question.mediaName).substring(0,5) === 'video';
  } else if (question.type == 'picture') {
    return mime.lookup(question.mediaName).substring(0,5) === 'image';
  } else if (question.type == 'truefalse') {
    return question.option2.length == 0 && question.option3.length == 0;
  }
  return false
}

router.route('/questions/:categoryId').get(function(req, res) {
  Question.find({
    categoryId: req.params.categoryId
  }, function(err, questions) {
    if (err) {
      return res.status(500).json({
        error: 'Could not retrieve questions.'
      });
    }
    return res.json(questions);
  });
});

router.route('/questions')
  .post(function(req, res) {
    var question = new Question({
      categoryId: req.body.categoryId,
      type: req.body.type,
      text: req.body.text,
      answer: req.body.answer,
      option1: req.body.option1,
      option2: req.body.option2,
      option3: req.body.option3,
      mediaName: req.body.mediaName,
      duration: req.body.duration,
      explanation: req.body.explanation
    });

    if(!isValidQuestion(question)) {
      return res.status(500).json({error: "Question is not valid."});
    }

    question.save(function(err, question) {
      if (err) {
        return res.status(500).json({
          error: 'Could not save question.'
        });
      }
      return res.json(question);
    });
  });

router.route('/questions')
  .delete(function(req, res) {
    Question.remove({
      _id: req.body._id
    }, function(err) {
      if (!err) {
        return res.status(200).json({
          msg: "Question deleted."
        });
      } else {
        return res.status(500).json({
          error: "Could not delete question."
        });
      }
    });
  });

router.route('/questions')
  .put(function(req, res) {
    var id = req.body.question._id;
    delete req.body.question._id;

    Question.findOneAndUpdate({
      _id: id
    }, req.body.question, function(err, question) {
      if (err) {
        return res.status(500).json({
          error: "Could not update question."
        });
      } else {
        return res.status(200).json(question);
      }
    });
  });

router.loadQuestions = function(categoryId, handler) {
  Question.find({
    categoryId: categoryId
  }, function(err, questions) {
    if (err) {
      handler(null, err);
    }
    handler(questions);
  });
}

module.exports = router;
