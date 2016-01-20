//
//  AppDelegate.m
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 31/07/12.
//  Copyright (c) 2012 Heven Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "HAQuizDataManager.h"
#import "HAUtilities.h"
#import "GameCenterManager.h"
#import "HATurnbasedMatchHelper.h"
#import "Appirater.h"

#define kEnableSettingsValidity YES

@implementation AppDelegate
@synthesize _navController;
@synthesize window = _window;
@synthesize _shouldRotate;


+(void)initialize
{
    //set the required data format used
    [HASettings sharedManager];
    [HAQuizDataManager sharedManager];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    //sleep(2.0);
//    if (kEnableSettingsValidity) {
//        [[HASettings sharedManager] validateSettings];
//    }
    
    // please check link https://github.com/arashpayan/appirater/ for below configurations for rating app
    [Appirater setAppId:@"954164220"]; //configure your appid here before uploading to appstore
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:2];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:YES]; // Set this to NO before uploading to appstore
    [Appirater appLaunched:YES];
    //------------    
        if ([[HASettings sharedManager] requiredAdDisplay])
        {                
            [Chartboost startWithAppId:kChartboostAppID
                          appSignature:kChartboostAppSignature
                              delegate:self];
            [Chartboost showInterstitial:CBLocationHomeScreen];
            
            //revmob ads
            [RevMobAds startSessionWithAppID:kRevmobAppID andDelegate:self];
        }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    HAMainViewController* controller = [[HAMainViewController alloc] initWithNibName:@"HAMainViewController" bundle:nil];
    _navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.window setRootViewController:_navController];
    [self.window makeKeyAndVisible];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [_navController.navigationBar setTranslucent:YES];
    _navController.navigationBar.shadowImage = [UIImage new];
    [_navController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    _navController.navigationBar.shadowImage = [[UIImage alloc] init];
    _navController.navigationBar.backgroundColor = [UIColor clearColor];
    _navController.navigationBar.tintColor = [UIColor whiteColor];
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent; // For light status bar
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([HASettings sharedManager]._isGameCenterSupported)
    {
        [[HATurnbasedMatchHelper sharedInstance] authenticateLocalUser];
    }
    
    if ([HASettings sharedManager]._isGameScreenVisible) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"skipCurrentQuestion" object:nil];
    }
    
    if ([[HASettings sharedManager] requiredAdDisplay] && [HASettings sharedManager]._isGameScreenVisible)
    {
        RevMobPopup *popup = [[RevMobAds session] popup];
        
        [popup loadWithSuccessHandler:^(RevMobPopup *popup) {
            [popup showAd];
        } andLoadFailHandler:^(RevMobPopup *popup, NSError *error) {
            [self revmobAdDidFailWithError:error];
        } onClickHandler:^(RevMobPopup *popup) {
        }];

    }
    else if ([[HASettings sharedManager] requiredAdDisplay]) {
        [[RevMobAds session] showFullscreen];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

#ifdef IOS_NEWER_THAN_OR_EQUAL_6
- (NSUInteger)application:(UIApplication*)application
supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    if(self._shouldRotate ) 
    {
        return (UIInterfaceOrientationMaskAll);
    }
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}
#endif

- (void)showActivityIndicator
{
    if (!_activityView)
    {
        _activityView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _activityView.alpha = 0.5;
        _activityView.backgroundColor = [UIColor blackColor];
         _activityIndicatorView = [[IMGActivityIndicator alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 150.0)];
        [_activityView addSubview:_activityIndicatorView];
    }
    _activityView.hidden = NO;
    [self.window addSubview:_activityView];
    _activityIndicatorView.center = _activityView.center;
    _activityView.center = self.window.center;
}


- (void)hideActivityIndicator
{
    _activityView.hidden = YES;
}


#pragma mark - Chartboost delegates
/*
 * didDismissInterstitial
 *
 * This is called when an interstitial is dismissed
 *
 * Is fired on:
 * - Interstitial click
 * - Interstitial close
 *
 * #Pro Tip: Use the delegate method below to immediately re-cache interstitials
 */

- (void)didDismissInterstitial:(NSString *)location {
    NSLog(@"dismissed interstitial at location %@", location);
    [Chartboost cacheInterstitial:location];
}


/*
 * shouldRequestInterstitialsInFirstSession
 *
 * This sets logic to prevent interstitials from being displayed until the second startSession call
 *
 * The default is NO, meaning that it will always request & display interstitials.
 * If your app displays interstitials before the first time the user plays the game, implement this method to return NO.
 */

- (BOOL)shouldRequestInterstitialsInFirstSession {
    return YES;
}


#pragma mark - Revmob delegates
-(void)revmobSessionIsStarted {
    NSLog(@"[RevMob Sample App] Session is started.");
}

- (void)revmobSessionNotStartedWithError:(NSError *)error {
    NSLog(@"[RevMob Sample App] Session failed to start: %@", error);
}

- (void)revmobAdDidFailWithError:(NSError *)error {
    NSLog(@"revmobAdDidFailWithError: %@", error);
}


@end
