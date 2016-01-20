//
//  HAUtilities.h
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 14/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAUtilities : NSObject
{
    
}
+ (void)fadeInOutView:(UIView *)inView withDuration:(CGFloat)inDuration;
+ (BOOL)isInternetConnectionAvailable;
+ (BOOL)isCurrent_iOSVersionIsBelow5;
+ (NSString *)nibNameForString:(NSString *)inNibName;
+ (NSString *)resourceNameForString:(NSString *)inResourceName;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (void)playTapSound;
+ (void)playSoundForCorrectAns:(BOOL)ans;
+ (NSString *)MD5StringForString:(NSString *)inString;
+ (void)setAppTextColorForLabel:(UILabel *)inLabel;
+ (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
+ (UIImage *)appScreenShot;
@end
