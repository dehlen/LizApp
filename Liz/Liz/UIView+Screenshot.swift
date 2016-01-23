import UIKit

extension UIView {

	func takeScreenshot() -> UIImage {
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.mainScreen().scale)
		drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)

		let screenshot = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return screenshot
	}
}
