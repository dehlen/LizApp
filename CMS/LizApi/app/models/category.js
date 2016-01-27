var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var CategorySchema   = new Schema({
	name:String,
	createdAt:String,
	description:String,
	timeBased:Boolean,
	themeColor:String,
	questionLimit:Number,
	leaderboardId:String,
	productIdentifier:String,
	online:Boolean,
	iconName:String
});

module.exports = mongoose.model('Category', CategorySchema);