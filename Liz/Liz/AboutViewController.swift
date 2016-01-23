import UIKit

class AboutViewController: UIViewController, UIWebViewDelegate {
	@IBOutlet weak var bgImageView: UIImageView!
	@IBOutlet weak var aboutTextView: UITextView!
	@IBOutlet weak var homeButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var webView: UIWebView!

	let shouldDisplayWebview: Bool = {
	    let textOrURL = Config.aboutScreenTextOrURL
	    return NSURL(string:textOrURL) != nil
	}()

    override func viewDidLoad() {
        super.viewDidLoad()

	    if self.shouldDisplayWebview {
      		let url = NSURL(string:Config.aboutScreenTextOrURL)!
			let request = NSURLRequest(URL:url)
			self.webView.loadRequest(request)
	    } else {
	        self.aboutTextView.text = Config.aboutScreenTextOrURL
	        self.aboutTextView.textColor = Config.Theme.appTextColor
	        self.aboutTextView.hidden = false
	        self.webView.hidden = true
	    }

	    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.homeButton)
		self.homeButton.setTitleColor(Config.Theme.appTextColor, forState:.Normal)
	    self.navigationItem.titleView = self.titleLabel

	    self.navigationController?.navigationBar.translucent = true
	    self.navigationController?.navigationBar.shadowImage = UIImage()
	    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics:.Default)
	    self.navigationController?.navigationBar.shadowImage = UIImage()
	    self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func homeAction() {
	    self.webView.delegate = nil
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	    self.dismissViewControllerAnimated(true, completion:nil)
	}

    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
