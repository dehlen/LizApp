import UIKit

extension UIView {

    private enum AnimationKey:String {
        case Rotation = "rotationAnimation"
    }
    
	func runSpinAnimation(duration:Double, rotation:CGFloat, repeatCount:Float) {
	    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
	    rotationAnimation.toValue = CGFloat(M_PI) * 2.0 * rotation * CGFloat(duration)
	    rotationAnimation.duration = duration
	    rotationAnimation.cumulative = true
	    rotationAnimation.repeatCount = repeatCount
    
	    self.layer.addAnimation(rotationAnimation, forKey:AnimationKey.Rotation.rawValue)
	}
	
	func fadeInAndOut(duration:NSTimeInterval) {
		fadeIn(duration)
		fadeOut(duration, delay: duration)
	}
	
	private func fadeIn(duration: NSTimeInterval = 1.0, delay:NSTimeInterval = 0.0) {
		UIView.animateWithDuration(duration, delay:delay, options:[.CurveEaseIn], animations: {
			self.alpha = 1.0
		}, completion:nil)
	}
	
	private func fadeOut(duration: NSTimeInterval = 1.0, delay:NSTimeInterval = 0.0) {
		UIView.animateWithDuration(duration, delay:delay, options:[.CurveEaseOut], animations: {
			self.alpha = 0.0
		}, completion:nil)
	}
}