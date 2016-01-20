//
//  HAUtilities.m
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 14/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import "HAUtilities.h"
#import "Reachability.h"
#import "HAQuizDataManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

@implementation UINavigationItem (ArrowBackButton)

static char kArrowBackButtonKey;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method m1 = class_getInstanceMethod(self, @selector(backBarButtonItem));
        Method m2 = class_getInstanceMethod(self, @selector(arrowBackButton_backBarButtonItem));
        method_exchangeImplementations(m1, m2);
    });
}

- (UIBarButtonItem *)arrowBackButton_backBarButtonItem {
    UIBarButtonItem *item = [self arrowBackButton_backBarButtonItem];
    if (item) {
        return item;
    }
    
    item = objc_getAssociatedObject(self, &kArrowBackButtonKey);
    if (!item) {
        item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        objc_setAssociatedObject(self, &kArrowBackButtonKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return item;
}
@end


@implementation HAUtilities
+ (void)fadeInOutView:(UIView *)inView withDuration:(CGFloat)inDuration
{
    [HAUtilities fadeIn:inView withDuration:inDuration andWait:0.0];
    [HAUtilities fadeOut:inView withDuration:inDuration  andWait:inDuration];
}

+ (void)fadeOut:(UIView*)viewToDissolve withDuration:(NSTimeInterval)duration  andWait:(NSTimeInterval)wait
{
    [UIView beginAnimations: @"Fade Out" context:(__bridge void*)viewToDissolve];
    // wait for time before begin
    [UIView setAnimationDelay:wait];
    
    // druation of animation
    [UIView setAnimationDuration:duration];
    viewToDissolve.alpha = 1.0;
    [UIView commitAnimations];
}

+ (void)fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration andWait:(NSTimeInterval)wait
{
    [UIView beginAnimations: @"Fade In" context:nil];    
    // wait for time before begin
    [UIView setAnimationDelay:wait];
    
    // druation of animation
    [UIView setAnimationDuration:duration];
    viewToFadeIn.alpha = 0.0;
    [UIView commitAnimations];
    
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    
}

+ (BOOL)isInternetConnectionAvailable
{
    Reachability *reachablity = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reachablity currentReachabilityStatus];
    
    if(status == kNotReachable)
    {
        return NO;
    }
    else if(status == kReachableViaWiFi)
    {
        return YES;
    }
    else if(status == kReachableViaWWAN)
    {
        return YES;
    }

    return YES;
}

+(BOOL)isCurrent_iOSVersionIsBelow5
{
    NSString* versionStirng = [[UIDevice currentDevice] systemVersion];
NSLog(@"versionStirng : %@",versionStirng);
    
    if ([versionStirng hasPrefix:@"5"] || [versionStirng hasPrefix:@"6"])
    {
        return NO;
    
    }
    return YES;
}

//
+(NSString *)nibNameForString:(NSString *)inNibName
{
    NSString* nibName = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nibName = [[NSString alloc] initWithString:[inNibName stringByAppendingString:@"_ipad"]];
    }
    else 
    {
        nibName = inNibName;
    }
    return nibName;
}

+ (NSString *)resourceNameForString:(NSString *)inResourceName
{
    NSString* resourceName = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        resourceName = [[NSString alloc] initWithString:[inResourceName stringByAppendingString:@"_ipad.png"]];
    }
    else 
    {
        resourceName = inResourceName;
    }
    return resourceName;

}


+ (UIColor *)colorFromHexString:(NSString *)hexString{
    if (hexString == nil) {
        return [UIColor whiteColor];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (void)playTapSound
{
    if ([HASettings sharedManager]._isSoundsOn)
    {
        NSURL* fileName = nil;
        fileName = [[NSBundle mainBundle] URLForResource:@"tap" withExtension:@"mp3"];
        
        SystemSoundID soundID = 0;
        CFURLRef soundFileURL = (__bridge CFURLRef)fileName;
        OSStatus errorCode = AudioServicesCreateSystemSoundID(soundFileURL, &soundID);
        if (errorCode != 0) {
            // Handle failure here
        }
        else
            AudioServicesPlaySystemSound(soundID);
    }
}

+ (void)playSoundForCorrectAns:(BOOL)ans
{
    NSURL* fileName = nil;
    if (ans) {
        fileName = [[NSBundle mainBundle] URLForResource:@"right" withExtension:@"wav"];
    }
    else{
        fileName = [[NSBundle mainBundle] URLForResource:@"wrong" withExtension:@"wav"];
    }
    
    SystemSoundID soundID = 0;
    CFURLRef soundFileURL = (__bridge CFURLRef)fileName;
    OSStatus errorCode = AudioServicesCreateSystemSoundID(soundFileURL, &soundID);
    if (errorCode != 0) {
        // Handle failure here
    }
    else
        AudioServicesPlaySystemSound(soundID);
}

+ (NSString *)MD5StringForString:(NSString *)inString
{
    const char *cstr = [inString UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (uint32_t)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (void)setAppTextColorForLabel:(UILabel *)inLabel
{
    inLabel.textColor = [HASettings sharedManager]._appTextColor;
}

+ (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


+ (UIImage *)appScreenShot
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capturedScreen;
}

@end
