var express    = require('express');
var app        = express();
var bodyParser = require('body-parser');
var mongoose   = require('mongoose');
var path       = require('path');
var multer = require('multer');
var dbConfig = require('./app/db.js');
mongoose.connect(dbConfig.url);

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.use('/uploads',express.static(path.join(__dirname, 'public/uploads')));
app.use('/', express.static(path.join(__dirname, 'public/frontend')));
app.use(multer({
    dest: path.join(__dirname, 'public/uploads')
}).single('file'));

app.set('view engine', 'jade');
app.set('views', path.join(__dirname, 'public/frontend/views'));

var port = process.env.PORT || 8080;

app.use(require('./app/routes/controller'));
app.listen(port);

console.log('Liz API started on ' + port);
