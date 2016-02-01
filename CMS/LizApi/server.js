var express    = require('express');
var app        = express();
var bodyParser = require('body-parser');
var mongoose   = require('mongoose');
var path       = require('path');
var multer = require('multer');
var fs = require('fs');
var Category   = require('./app/models/category');
var Question   = require('./app/models/question');

mongoose.connect('mongodb://localhost/liz');

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use('/uploads',express.static(path.join(__dirname, 'public/uploads')));
app.use('/', express.static(path.join(__dirname, 'public/frontend')));
app.use(multer({
    dest: path.join(__dirname, 'public/uploads')
}).single('file'));
app.set('view engine', 'jade');
app.set('views', path.join(__dirname, 'public/frontend'))
var port = process.env.PORT || 8080;
var router = express.Router();

/* == Middleware == */
function logger(req,res,next){
  console.log(new Date(), req.method, req.url);
  next();
}
router.use(logger);

router.route('/upload').post(function(req, res) {
	
if (!req.file) {
		return res.status(404).json({error: 'No file information was found.'});
	}

	var uniqueName = 'file-'+(new Date()).getTime()+path.extname(req.file.originalname);
	var newPath = path.join(__dirname, 'public/uploads', uniqueName);
	fs.rename(req.file.path, newPath, function(err) {
    		if (err) {
			return res.status(500).json({error: 'Could not rename file.'});
		}
	});
	return res.json({'filename': uniqueName});
	
});

/* == Category Routes == */
router.route('/categories').get(function(req, res) {
	Category.find({}, function(err, categories) {
		if (err) {
			return res.status(500).json({error:'Could not retrieve categories.'});
		}
		return res.json(categories);
	});
});

router.route('/add/category')
.post(function(req, res) {
	var category = new Category({
			name: req.body.name,
			createdAt: req.body.createdAt,
			description: req.body.description,
			timeBased: req.body.timeBased,
			iconName: req.body.iconName,
			themeColor: req.body.themeColor,
			questionLimit: req.body.questionLimit,
			leaderboardId: req.body.leaderboardId,
			productIdentifier: req.body.productIdentifier,
			online: req.body.online
	});
	
	category.save(function(err, category) {
	  if (err) {
		  return res.status(500).json({error:'Could not save category.'});		  
	  }
	 return res.json(category);
	});
});

router.route('/delete/category')
.delete(function(req, res) {
	Category.remove({ _id: req.body._id }, function(err) {
	    if (!err) {
			return res.status(200).json({msg: "Category deleted."});
		} else {
			return res.status(500).json({error: "Could not delete category."});
	    }
	});
});

router.route('/update/category')
.post(function(req, res) {
  	var id = req.body.category._id;
    delete req.body.category._id;
	
	Category.findOneAndUpdate({ _id: id}, req.body.category, function(err, category) {
		if (err) {
			return res.status(500).json({error:"Could not update category."});
		} else {
			return res.status(200).json(category);
		}
	});
});

/* == Question Routes == */
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

app.use('/api', router);

app.get('/', function(req, res) {
  res.sendFile(path.join(__dirname + '/public/frontend/index.html'));
});

app.get('/question/:categoryId', function(req, res) {
  res.render('question', { categoryId: req.params.categoryId});
});

app.listen(port);
console.log('Liz API started on ' + port);
