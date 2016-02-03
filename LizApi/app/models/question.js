var random = require('mongoose-simple-random');
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
QuestionSchema.plugin(random);

module.exports = mongoose.model('Question', QuestionSchema);
