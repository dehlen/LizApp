//TODO:
//Client:
//Edit Categories and Questions
//paginate table

//Server:
//Question type and media validation
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
