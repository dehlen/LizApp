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
    res.send('Liz API v1.0');   
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
	  res.json(category);
	});
});

router.route('/delete/category')
.delete(function(req, res) {
	Category.remove({ _id: req.body._id }, function(err) {
	    if (!err) {
			res.status(200).json({msg: "Category deleted."});
		} else {
			res.status(500).json({error: "Could not delete category."});
	    }
	});
});

router.route('/update/category')
.post(function(req, res) {
  	var id = req.body.category._id;
    delete req.body.category._id;
	
	Category.findOneAndUpdate({ _id: id}, req.body.category, function(err, category) {
		if (err) {
			res.status(500).json({error:"Could not update category."});
		} else {
			res.status(200).json(category);
		}
	});
});

app.use('/api', router);

app.listen(port);
console.log('Liz API started on ' + port);