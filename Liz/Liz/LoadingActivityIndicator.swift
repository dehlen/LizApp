import UIKit

class LoadingActivityIndicator: UIView {

	private let kStrokeStart = "strokeStart"
	private let kStrokeEnd = "strokeEnd"
    private let circleLineWidth: CGFloat = 1.65
	private let duration = 1.4

    private let strokeTimings = [0.35, 0.50, 0.65, 0.80, 0.95]
    private let radii: [CGFloat] = [16.0, 13.0, 10.0, 7.0, 4.0]
    private var shapeLayers: [CAShapeLayer] = []
	private var timer: CADisplayLink = CADisplayLink()

	private let strokeColor = UIColor.whiteColor()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
		self.createLayers()
    }

    override init(frame: CGRect) {
        super.init(frame:frame)
		self.createLayers()
    }

    private func createLayers() {
        let backgroundView = UIView(frame:CGRect(x: 0, y: 0, width: CGRectGetWidth(self.frame),
            height: CGRectGetHeight(self.frame)))
		backgroundView.layer.borderColor = UIColor.blackColor().CGColor
		backgroundView.backgroundColor = UIColor(white:0.1, alpha:1.0)

		let dot = UIBezierPath(arcCenter: CGRectGetCenter(backgroundView.frame),
            radius: self.circleLineWidth, startAngle:-0.5 * CGFloat(M_PI), endAngle:1.5 * CGFloat(M_PI), clockwise:true)
		let dotLayer = CAShapeLayer()
		dotLayer.path = dot.CGPath
		dotLayer.fillColor = UIColor.whiteColor().CGColor
		backgroundView.layer.addSublayer(dotLayer)

		5.times { [unowned self] (index: Int) in
		    let circleLayer = CAShapeLayer()
			let radius = self.radii[index]
			let path = UIBezierPath(arcCenter: self.CGRectGetCenter(backgroundView.frame),
                radius: radius, startAngle:-0.5 * CGFloat(M_PI), endAngle:1.5 * CGFloat(M_PI), clockwise:true)
			circleLayer.path = path.CGPath
			circleLayer.strokeColor = self.strokeColor.CGColor
			circleLayer.lineWidth = self.circleLineWidth
			circleLayer.fillColor = nil
			circleLayer.contentsScale = UIScreen.mainScreen().scale

			self.shapeLayers.append(circleLayer)
			backgroundView.layer.addSublayer(circleLayer)
		}

		backgroundView.backgroundColor = UIColor.clearColor()
		self.addSubview(backgroundView)
		self.loopAnimations()

		self.timer = CADisplayLink(target:self, selector:"loopAnimations")
		self.timer.frameInterval = 60 * 2 * Int(duration)
		self.timer.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
	}

	private func loopAnimations() {
		5.times { [unowned self] (index: Int) in
			let circleLayer = self.shapeLayers[index]
			let timeDuration = self.strokeTimings[index]

			let strokeStartAnimation = CABasicAnimation(keyPath:self.kStrokeStart)
			strokeStartAnimation.fromValue = 0
			strokeStartAnimation.toValue = 1.08
			strokeStartAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
			strokeStartAnimation.beginTime = CACurrentMediaTime() + timeDuration
			strokeStartAnimation.duration = self.duration
			circleLayer.addAnimation(strokeStartAnimation, forKey:nil)

			let strokeEndAnimation = CABasicAnimation(keyPath:self.kStrokeEnd)
			strokeEndAnimation.fromValue = 0
			strokeEndAnimation.toValue = 1.08
			strokeEndAnimation.duration = self.duration
			strokeEndAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
			strokeEndAnimation.beginTime = CACurrentMediaTime() + timeDuration + self.duration
			circleLayer.addAnimation(strokeEndAnimation, forKey:nil)
		}
	}

    private func CGRectGetCenter(rect: CGRect) -> CGPoint {
        return CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect))
    }
}
