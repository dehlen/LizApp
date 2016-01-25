var express    = require('express');
var app        = express();
var bodyParser = require('body-parser');
var mongoose   = require('mongoose');
var Category       = require('./app/models/category');

mongoose.connect('mongodb://localhost/liz');

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.static(__dirname + '/public'));

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

/* == Category Routes == */
router.route('/categories').get(function(req, res) {
	Category.find({}, function(err, categories) {
		if (err) {
			return res.status(500).send('Could not retrieve categories');
		}
		return res.json(categories);
	    });
});
router.route('/add/category')
.post(function(req, res) {
	console.log(req.body);
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
		  return res.status(500).send('Could not save category in the database.');
	  }
	  res.json(category);
	});
});

router.route('/delete/category')
.delete(function(req, res) {
	Category.remove({ _id: req.body.categoryId }, function(err) {
	    if (!err) {
			res.status(200).json({"msg": "Category deleted."});
		} else {
			res.status(500).json({"msg": "Could not delete this category."});
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