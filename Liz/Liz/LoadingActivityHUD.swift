import UIKit

class LoadingActivityHUD {
	private let window = (UIApplication.sharedApplication().delegate?.window)!
	static let sharedInstance = LoadingActivityHUD()

    lazy var activityView: UIView = {
        let tempActivityView = UIView(frame:UIScreen.mainScreen().bounds)
        tempActivityView.alpha = 0.5
        tempActivityView.backgroundColor = UIColor.blackColor()
		tempActivityView.addSubview(self.activityIndicatorView)
		tempActivityView.hidden = true

        return tempActivityView
	}()

	var activityIndicatorView: LoadingActivityIndicator {
        let tempActivityIndicatorView = LoadingActivityIndicator(frame:
            CGRect(x: 0.0, y: 0.0, width: 150.0, height: 150.0))
		return tempActivityIndicatorView
	}

	func displayLoadingIndicator() {
        guard let keyWindow = self.window else {
            return
        }
	    self.activityView.hidden = false
	    self.activityIndicatorView.center = self.activityView.center
	    self.activityView.center = keyWindow.center
		keyWindow.addSubview(self.activityView)
	}

	func hideLoadingIndicator() {
		self.activityView.hidden = true
		self.activityView.removeFromSuperview()
	}
}
