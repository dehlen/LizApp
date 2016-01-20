import UIKit

class ThemeableLabel : UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setAppTextColor()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.setAppTextColor()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppTextColor()
    }
    
    func setAppTextColor() {
        self.textColor = Config.ui.appTextColor
    }
}