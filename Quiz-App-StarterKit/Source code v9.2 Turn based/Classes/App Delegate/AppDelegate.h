//
//  AppDelegate.h
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 31/07/12.
//  Copyright (c) 2012 Heven Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMainViewController.h"
#import <Chartboost/Chartboost.h>
#import <RevMobAds/RevMobAds.h>
#import "IMGActivityIndicator.h"


@class HAQuizCategoriesViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, ChartboostDelegate, RevMobAdsDelegate>
{
    UINavigationController* _navController;
    UIWindow* window;
    BOOL _shouldRotate;
    
    UIView* _activityView;
    IMGActivityIndicator* _activityIndicatorView;
}

@property (nonatomic, assign) BOOL _shouldRotate;
@property (nonatomic, strong)  UIWindow *window;
@property (nonatomic, readonly) UINavigationController* _navController;
@property (nonatomic, assign) BOOL _takeAnotherChallenge;

- (void)showActivityIndicator;
- (void)hideActivityIndicator;
@end
