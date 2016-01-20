//
//  IMGActivityIndicator.m
//  IMGActivityIndicator
//
/*The MIT License (MIT)
 
 Copyright (c) 2014 Maijid Moujaled
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.*/

#import "IMGActivityIndicator.h"

static const CGFloat IMGCircleLineWidth = 1.65;
static const CGFloat IMGDuration = 1.4; // Duration for every stroke cycle

// Helper Function to get center of CGRect
CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

@interface IMGActivityIndicator ()

@property (nonatomic, strong) NSMutableArray *shapeLayers;
@property (nonatomic, strong) NSArray *strokeTimings;
@property (nonatomic, strong) CADisplayLink *timer;

@end

@implementation IMGActivityIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _strokeColor = [UIColor whiteColor];
        [self createLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _strokeColor = [UIColor whiteColor];
        [self createLayers];
    }
    return self;
}

- (void)createLayers
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 ,CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    backgroundView.layer.borderColor = [UIColor blackColor].CGColor;
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    
    self.shapeLayers = [NSMutableArray new];
    
    // Draw the middle dot.
    UIBezierPath *dot =[UIBezierPath bezierPathWithArcCenter:CGRectGetCenter(backgroundView.frame)
                                                      radius:IMGCircleLineWidth
                                                  startAngle:-0.5 * M_PI
                                                    endAngle:1.5 * M_PI
                                                   clockwise:YES];
    
    CAShapeLayer *dotLayer = [CAShapeLayer layer];
    dotLayer.path = dot.CGPath;
    dotLayer.fillColor = [UIColor whiteColor].CGColor;
    [backgroundView.layer addSublayer:dotLayer];
    
    self.strokeTimings = @[@0.35, @0.50, @0.65, @0.80, @0.95];
    NSArray *radii = @[@16, @13, @10, @7, @4];
    
    // Draw our looping stroke lines
    for (int i = 0; i < 5; i++) {
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        CGFloat radius = [radii[i] floatValue];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGRectGetCenter(backgroundView.frame)
                                                            radius:radius
                                                        startAngle:-0.5 * M_PI
                                                          endAngle:1.5 * M_PI
                                                         clockwise:YES];
        
        circleLayer.path = path.CGPath;
        circleLayer.strokeColor = self.strokeColor.CGColor;
        circleLayer.lineWidth = IMGCircleLineWidth;
        circleLayer.fillColor = nil;
        circleLayer.contentsScale = [UIScreen mainScreen].scale;
        
        [self.shapeLayers addObject:circleLayer];
        [backgroundView.layer addSublayer:circleLayer];
    }
    
    backgroundView.backgroundColor = [UIColor clearColor];
    [self addSubview:backgroundView];
    [self loopAnimations];

    // Use a CADisplayLink timer to fire every time we need to reloop both stroke start and end animation.
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(loopAnimations)];
    self.timer.frameInterval = 60 * 2 * IMGDuration;
    [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

/*
 *For every loop (in 3.33s) we add both our strokeStart and strokeEnd animations for the next looping cycle.
 */
- (void)loopAnimations
{
    for (int i = 0; i < 5; i++) {
        
        CAShapeLayer *circleLayer = self.shapeLayers[i];
        CGFloat timeDuration =  [self.strokeTimings[i] floatValue];
        
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0;
        strokeStartAnimation.toValue = @1.08;
        strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        strokeStartAnimation.beginTime = CACurrentMediaTime() + timeDuration;
        strokeStartAnimation.duration = IMGDuration;
        [circleLayer addAnimation:strokeStartAnimation forKey:nil];
        
        CABasicAnimation *strokEndAnimation  = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokEndAnimation.fromValue = @0;
        strokEndAnimation.toValue = @1.08;
        strokEndAnimation.duration = IMGDuration;
        strokEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        strokEndAnimation.beginTime = CACurrentMediaTime() + timeDuration + IMGDuration;
        [circleLayer addAnimation:strokEndAnimation forKey:nil];
    }
}

@end
