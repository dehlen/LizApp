var express = require('express');
var Category   = require('../models/category');
var router = express.Router();
	
router.route('/categories').get(function(req, res) {
	Category.find({}, function(err, categories) {
		if (err) {
			return res.status(500).json({error:'Could not retrieve categories.'});
		}
		return res.json(categories);
	});
});

router.route('/categories')
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

router.route('/categories')
.delete(function(req, res) {
	Category.remove({ _id: req.body._id }, function(err) {
	    if (!err) {
			return res.status(200).json({msg: "Category deleted."});
	    } else {
			return res.status(500).json({error: "Could not delete category."});
	    }
	});
});

router.route('/categories')
.put(function(req, res) {
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

router.loadCategories = function(handler) {
	Category.find({}, function(err, categories) {
                if (err) {
                        handler(null,err);
                }
                handler(categories);
        });
}

module.exports = router
