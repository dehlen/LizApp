var express    = require('express');
var app        = express();
var bodyParser = require('body-parser');
var mongoose   = require('mongoose');
var filesystem = require('./app/filesystem');
var Category       = require('./app/models/category');

mongoose.connect('mongodb://localhost/liz');

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

var port = process.env.PORT || 8080;
var router = express.Router();

/* == Middleware == */
function logger(req,res,next){
  console.log(new Date(), req.method, req.url);
  next();
}
router.use(logger);

/* == API Routes  == */
router.get('/', function(req, res) {
    res.json({ message: 'Liz API v1.0' });   
});

/* Category Routes */
router.route('/upload')
.post(function(req, res) {
	var iconPath = storeCategoryIcon(req.body.file_data, req.body.fileInfo.name)
	
	Category.findById(req.body.fileInfo.name, function(err, category) {
		if (!category) {
			res.status(404).send("Could not find a category for this icon.");
		} else {
			category.iconPath = iconPath;
			category.save(function(err) {
				if (err) {
					res.status(500).send("Could not save the icon for this category.");
				} else {
					res.status(200).send("Uploaded successfully.");
		  	  	}
	    	});
		}
	});
});

router.route('/add/category')
.post(function(req, res) {
	var category = new Category({
			name: req.body.name,
			createdAt: req.body.createdAt,
			description: req.body.description,
			timeBased: req.body.timeBased,
			themeColor: req.body.themeColor,
			questionLimit: req.body.questionLimit,
			leaderboardId: req.body.leaderboardId,
			productIdentifier: req.body.productIdentifier,
			online: req.body.online
	});
	
	category.save(function(err, category) {
	  if (err) {
		  return res.status(500).send('Could not save category in the database.');
	  }
	  res.json(category);
	});
});

router.route('/delete/category')
.post(function(req, res) {
	Category.remove({ _id: req.body.categoryId }, function(err) {
	    if (!err) {
			res.status(200).send("Category deleted.");
		} else {
			res.status(500).send("Could not delete this category.");
	    }
	});
});

router.route('/update/category')
.post(function(req, res) {
	res.status(200).send("Need to implement !");
});

app.use('/api', router);

app.listen(port);
console.log('Liz started on ' + port);