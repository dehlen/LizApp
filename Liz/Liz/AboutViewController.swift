import UIKit

class AboutViewController: UIViewController, UIWebViewDelegate {
	@IBOutlet weak var aboutTextView: UITextView!
	@IBOutlet weak var homeButton: UIBarButtonItem!
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

		self.homeButton.tintColor = Config.Theme.appTextColor
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        log.error("Did receive memory warning. Might be a memory leak.")
    }

	@IBAction func home() {
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
