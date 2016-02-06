var random = require('mongoose-simple-random');
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var QuestionSchema = new Schema({
  categoryId: {
    type: String,
    required: true
  },
  type: {
    type: String,
    default: 'text'
  },
  text: {
    type: String,
    required: true
  },
  answer: {
    type: String,
    required: true
  },
  option1: {
    type: String,
    required: true
  },
  option2: String,
  option3: String,
  mediaName: {
    type: String,
    default: 'placeholder.png'
  },
  duration: {
    type: Number,
    default: 30
  },
  explanation: String
});
QuestionSchema.plugin(random);

module.exports = mongoose.model('Question', QuestionSchema);
