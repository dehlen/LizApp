import UIKit

class CategoryTableViewCell : UITableViewCell {
	
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var highscoreLabel:UILabel!
	@IBOutlet weak var timeLimitLabel:UILabel!
	@IBOutlet weak var priceLabel:UILabel!
	@IBOutlet weak var buyButton:UIButton!
	@IBOutlet weak var categoryImageView:UIImageView!
	@IBOutlet weak var categoryBGImageView:UIImageView!
	@IBOutlet weak var descriptionLabel:UILabel!
	@IBOutlet weak var progressView:UIProgressView!
	@IBOutlet weak var percentageLabel:UILabel!
	@IBOutlet weak var highscoreDisplayLabel:UILabel!
	
	override func awakeFromNib() {
	    //TODO: set progressview height to 4.0 via autolayout constraints
		self.buyButton.setTitleColor(Config.ui.appTextColor, forState:.Normal) 
	}		
}