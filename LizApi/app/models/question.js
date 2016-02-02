var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var QuestionSchema = new Schema({
	categoryId:String,
	type:String,
	text:String,
	answer:String,
	option1:String,
	option2:String,
	option3:String,
	mediaName:String,
	duration:Number,
	explanation:String
});

module.exports = mongoose.model('Question', QuestionSchema);
