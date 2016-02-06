var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var CategorySchema = new Schema({
  name: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  description: String,
  timeBased: {
    type: Boolean,
    default: false
  },
  themeColor: {
    type: String,
    required: true
  },
  questionLimit: {
    type: Number,
    default: 10
  },
  leaderboardId: String,
  productIdentifier: String,
  online: {
    type: Boolean,
    default: false
  },
  iconName: {
    type: String,
    default: 'placeholder.png'
  }
});

module.exports = mongoose.model('Category', CategorySchema);
