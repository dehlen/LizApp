//
//  HAMainViewController.m
//  QUIZ_APP
//
//  Created by NIDHI on 29/06/13.
//
//

#import "HAMainViewController.h"
#import "HAQuizCategoriesViewController.h"
#import "HAAboutViewController.h"
#import "RageIAPHelper.h"
#import "AppDelegate.h"
#import "HAQuizPurchaseCategoriesViewController.h"
#import "HASettingsViewController.h"
#import "HATurnbasedMatchHelper.h"
#import "SBJSON.h"
#import "HAGameViewController.h"
#import "HATurnbasedFinalViewController.h"

@interface HAMainViewController (Private)
- (void)initialization;
@end

@implementation HAMainViewController (Private)
- (void)initialization
{
    self._dataManager = [HAQuizDataManager sharedManager];
}
@end

@implementation HAMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[HAUtilities nibNameForString:nibNameOrNil] bundle:nibBundleOrNil];
    if (self) {
        [self initialization];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.clipsToBounds = YES;
    
    
    //self._buttonsContainerView.center = self.view.center;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self._settingsButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self._aboutButton];


    NSMutableArray* buttons = [[NSMutableArray alloc] init];
    [buttons addObject:self._playButton];
    
    self._titleView.text = [HASettings sharedManager]._menuScreenTittle;
    self.navigationItem.titleView = self._titleView;
    
    
    if ([HASettings sharedManager]._isMultiplayerSupportEnabled && [HASettings sharedManager]._isGameCenterSupported)
    {
        [buttons addObject:self._challengeButton];
    }
    else{
        self._challengeButton.hidden = YES;
    }
    
    if (![HASettings sharedManager]._isInAppPurchaseSupported) {
        self._getMoreCategoriesButton.hidden = YES;
    }
    else{
        [buttons addObject:self._getMoreCategoriesButton];
    }

    if (![HASettings sharedManager]._isGameCenterSupported) {
        self._worldScoreButton.hidden = YES;
    }
    else{
        [buttons addObject:self._worldScoreButton];
    }
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].bounds.size.height == 480.0) {
            CGRect rect = self._buttonsContainerView.frame;
            rect.origin.y = 200.0;
            self._buttonsContainerView.frame = rect;
        }
    }
   

    
    for (UIButton* menuButton in buttons) {
        CGRect rect = menuButton.frame;
        rect.origin.y = 0.0;
        menuButton.frame = rect;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0.2];
    [UIView setAnimationDuration:0.5];
    CGRect initialRect = [[buttons objectAtIndex:0] frame];
    CGFloat initialY = initialRect.origin.y;
    for (int i=0; i<buttons.count; i++) {
        UIButton* button = [buttons objectAtIndex:i];
        initialRect.origin.y = ((button.frame.size.height) * i) + initialY;
        button.frame = initialRect;
        [button setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    }
    [UIView commitAnimations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:IAPHelperProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedToLoadProducts:) name:IAPHelperProductsFailedToLoadNotification object:nil];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    if ([[HASettings sharedManager] requiredAdDisplay])
    {
        [Chartboost showInterstitial:CBLocationHomeScreen];
        
        self._bannerAd = [[RevMobAds session] banner];
        [self._bannerAd loadWithSuccessHandler:^(RevMobBanner *banner) {
            [self._bannerAd showAd];
        } andLoadFailHandler:^(RevMobBanner *banner, NSError *error) {

        } onClickHandler:^(RevMobBanner *banner) {
        }];
    }
    
    if ([HASettings sharedManager]._isMultiplayerSupportEnabled) {
        [HATurnbasedMatchHelper sharedInstance].delegate = self;
    }
    
    AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appdelegate._takeAnotherChallenge) {
        [self multiplayerGameMode:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([[HASettings sharedManager] requiredAdDisplay])
    {
        [self._bannerAd hideAd];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action Methods

- (IBAction)getMoreCategories:(id)sender
{
    NSArray* purchaseCategories = [[HAQuizDataManager sharedManager] quizCategoriesRequirePurchase];
    if (purchaseCategories.count == 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"You have already purchased all categories." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    self._showGetMoreCategories = YES;
    [[RageIAPHelper sharedInstance] loadProducts];
}


- (IBAction)playQuiz:(id)sender
{
    [HASettings sharedManager]._isMultiplayerGame = NO;
    [HAUtilities playTapSound];
    HAQuizCategoriesViewController* controller = [[HAQuizCategoriesViewController alloc] initWithNibName:@"HAQuizCategoriesViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)worldScoreAction:(id)sender
{
    if ([HAUtilities isInternetConnectionAvailable]) {
        [HAUtilities playTapSound];
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        if (gameCenterController != nil)
        {
            gameCenterController.gameCenterDelegate = self;
            gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
            [self presentViewController:gameCenterController animated:YES completion:nil];
        }
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Network error" message:@"Please check your internet connection." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


- (IBAction)aboutAction:(id)sender
{
    [HAUtilities playTapSound];
    HAAboutViewController* controller = [[HAAboutViewController alloc] initWithNibName:@"HAAboutViewController" bundle:nil];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (IBAction)settingsAction:(id)sender
{
    [HAUtilities playTapSound];
    HASettingsViewController* controller = [[HASettingsViewController alloc] initWithNibName:@"HASettingsViewController" bundle:nil];
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navController animated:YES completion:^{
            
        }];
}

- (void)productsLoaded:(NSNotification *)nc
{
    if (self._showGetMoreCategories) {
        
        NSArray* categories = [[HAQuizDataManager sharedManager] quizCategoriesRequirePurchase];
        if (categories.count == 0) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"No categories available to buy." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            NSLog(@"HAQuizPurchaseCategoriesViewController");
            [HAUtilities playTapSound];
            HAQuizPurchaseCategoriesViewController* controller = [[HAQuizPurchaseCategoriesViewController alloc] initWithNibName:@"HAQuizPurchaseCategoriesViewController" bundle:nil];
            controller._quizCategoriesArray = categories;
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
            [self presentViewController:navController animated:YES completion:^{
                
            }];
        }
    }
}

- (void)failedToLoadProducts:(NSNotification *)nc
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Failed to load products, please try again later" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)productPurchased:(NSNotification *)notification {
    NSLog(@"notification : %@",[notification description]);
}

#pragma mark - Gamecentre delegates
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Multiplayer methods
- (IBAction)multiplayerGameMode:(id)sender
{
    if ([HAUtilities isInternetConnectionAvailable]) {
        [HAUtilities playTapSound];
        [HATurnbasedMatchHelper sharedInstance].delegate = self;
        AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [[HATurnbasedMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self showExistingMatches:!appdelegate._takeAnotherChallenge];
        appdelegate._takeAnotherChallenge = NO;
    }
    else{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Network error" message:@"Please check your internet connection." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - GCTurnBasedMatchHelperDelegate

- (void)enterNewGame:(GKTurnBasedMatch *)match
{
    NSLog(@"enter new game : %@",match.matchData);
    [HASettings sharedManager]._isMultiplayerGame = YES;
    [HAUtilities playTapSound];
    HAQuizCategoriesViewController* controller = [[HAQuizCategoriesViewController alloc] initWithNibName:@"HAQuizCategoriesViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)takeTurn:(GKTurnBasedMatch *)match
{
    [HASettings sharedManager]._isMultiplayerGame = YES;
    BOOL error = NO;
    if (match.matchData.length == 0) {
        return;
    }
    if (match.matchData.length > 0) {
            [HATurnbasedMatchHelper sharedInstance]._saveToLoseList = YES;
        }

    NSDictionary* quizDict = [[HAQuizDataManager sharedManager] dataDictionaryFromPreviousParticipantMatchData:match.matchData];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *currentVersion = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString* appVersion = [quizDict objectForKey:@"v"];
    
    BOOL isSameVersion = ([currentVersion compare:appVersion options:NSNumericSearch] == NSOrderedSame);
    if (isSameVersion) {
        
    }
    else{
        BOOL isNewer = ([currentVersion compare:appVersion options:NSNumericSearch] == NSOrderedDescending);
        if (isNewer == NO) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"UPDATE!"
                                                                           message:@"To accept this match, update your app to latest version"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //Do nothing
                                                             }];
            UIAlertAction* updateNowAction = [UIAlertAction actionWithTitle:@"Update now" style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * action)
                                              {
                                                  NSString* appURLString = [HASettings sharedManager]._applicationiTunesLink;
                                                  if (appURLString != nil) {
                                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURLString]];
                                                  }
                                              }];
            [alert addAction:okAction];
            [alert addAction:updateNowAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }
    NSDictionary* matchCategoryDict = [quizDict objectForKey:@"category"];
    NSDictionary* localCatgoryDict = [[HAQuizDataManager sharedManager] categoryDictForCategoryId:[[matchCategoryDict objectForKey:kQuizCategoryId] intValue]];
    
    BOOL alreadyPurchased = NO;
    if ([HASettings sharedManager]._isInAppPurchaseSupported) {
        if ([localCatgoryDict valueForKey:kProductIdentifier]) {
            if ([[NSUserDefaults standardUserDefaults] valueForKey:[localCatgoryDict valueForKey:kProductIdentifier]]) {
                alreadyPurchased = YES;
            }
            else{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:[NSString stringWithFormat:@"This match contains premium questions. To accept this match you need to buy \"%@\" quiz from \"More categories\"",[localCatgoryDict objectForKey:kQuizCategoryName]] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }
        }
        else{
            alreadyPurchased = YES;
        }
    }
    else{
        alreadyPurchased = YES;
    }
    
    if (alreadyPurchased == NO) {
        
    }
    
    if ([quizDict valueForKey:@"category"] == nil || [quizDict valueForKey:@"Questions"] == nil) {
        error = YES;
    }
    
    if (error) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"There is some game data issue with this match please play some other game" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate._shouldRotate = NO;
    NSDictionary* currentCategoryDict = [quizDict objectForKey:@"category"];
    self._dataManager._currentCategoryDict = currentCategoryDict;
    NSDecimalNumber* quizId  = [currentCategoryDict objectForKey:kQuizCategoryId];
    NSString* categoryName = [currentCategoryDict objectForKey:kQuizCategoryName];
    int quizIdInt = [quizId intValue];
    NSString* xibName = nil;
    if ([UIScreen mainScreen].bounds.size.height == 568.0) {
        xibName = @"HAGameViewController-568";
    }
    else{
        xibName = @"HAGameViewController";
    }
    self._dataManager._currentQuizCategory = quizIdInt;
    self._dataManager._currentQuizCategoryName = categoryName;
    HAGameViewController* controller = [[HAGameViewController alloc] initWithNibName:xibName bundle:nil];
    controller._questionsArray = [quizDict objectForKey:@"Questions"];
    controller._isTimerReQuired = [[currentCategoryDict objectForKey:kTimerRequired] boolValue];
    [controller startQuizForCategory:quizIdInt];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)layoutMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"Viewing match where it's not our turn...");
    NSString *statusString = nil;
    
    if (match.status == GKTurnBasedMatchStatusEnded) {
            HATurnbasedFinalViewController* controller = [[HATurnbasedFinalViewController alloc] initWithNibName:@"HATurnbasedFinalViewController" bundle:nil];
            controller._match = match;
            controller._isPushedFromGC = YES;
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
            [self presentViewController:navController animated:YES completion:^{
                
            }];
    } else
    {
            NSUInteger playerNum = [match.participants
                                    indexOfObject:match.currentParticipant] + 1;
            statusString = [NSString stringWithFormat:
                            @"Waiting for Player %lu's turn", (unsigned long)playerNum];
    }
    if (statusString != nil) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Status" message:statusString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


- (void)sendNotice:(NSString *)notice
          forMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"notice : %@",notice);
}

/*- (void)showChallengeBannerForMatch:(GKTurnBasedMatch *)match
{
    AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUInteger currentIndex = [match.participants
                               indexOfObject:match.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    nextParticipant = [match.participants objectAtIndex:
                       ((currentIndex + 1) % [match.participants count ])];

    self._gcBannerMessageLabel.text = [NSString stringWithFormat:@"New challenge from \"%@\"",nextParticipant.player.alias];
    [appdelegate.window addSubview:self._gcTopBannerView];
    CGRect rect = self._gcTopBannerView.frame;
    rect.origin.y = -self._gcTopBannerView.frame.size.height;
    self._gcTopBannerView.frame = rect;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self._gcTopBannerView.frame;
        rect.origin.y = 0;
        self._gcTopBannerView.frame = rect;
    } completion:^(BOOL finished) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2.0];
        CGRect rect = self._gcTopBannerView.frame;
        rect.origin.y = -self._gcTopBannerView.frame.size.height;
        self._gcTopBannerView.frame = rect;
    }];
}*/
@end
