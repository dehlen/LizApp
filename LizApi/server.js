//TODO:
//Client:
//Edit Categories and Questions
//paginate table
//question show media in video, audio, img or empty tag(for text and true/false)
//disable file input for text, disable option2 and option3 for truefalse
//set correct accept header for fileinput for picture, audio, video

var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var path = require('path');
var multer = require('multer');
var config = require('./app/config.js');

mongoose.connect(config.db.url);

app.use(bodyParser.urlencoded({
  extended: true
}));
app.use(bodyParser.json());

app.use('/uploads', express.static(path.join(__dirname, 'public/uploads')));
app.use('/', express.static(path.join(__dirname, 'public/frontend')));
app.use(multer({
  dest: path.join(__dirname, 'public/uploads')
}).single('file'));

app.set('view engine', 'jade');
app.set('views', path.join(__dirname, 'public/frontend/views'));

var port = process.env.PORT || config.server.port;

app.use(require('./app/routes/mainRouter'));
app.listen(port);

console.log('Liz API started on ' + port);
