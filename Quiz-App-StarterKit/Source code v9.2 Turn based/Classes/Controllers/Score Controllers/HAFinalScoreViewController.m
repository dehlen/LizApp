//
//  HAFinalScoreViewController.m
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 06/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import "HAFinalScoreViewController.h"
#import "HAQuizDataManager.h"
#import "HAUtilities.h"
#import <Social/Social.h>
#import "AppDelegate.h"


@interface HAFinalScoreViewController (Private)
- (void)customInitialization;
@end

@implementation HAFinalScoreViewController (Private)
- (void)customInitialization
{
    
}
@end

@implementation HAFinalScoreViewController
@synthesize _currentScore;
@synthesize _quizCategoryName;
@synthesize _hiscoresArray;
@synthesize gameCenterManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[HAUtilities nibNameForString:nibNameOrNil] bundle:nibBundleOrNil];
    if (self) {
        [self customInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInitialization];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* categoryColor = [HAUtilities colorFromHexString:[[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kCategoryColor]];
    self.view.backgroundColor = categoryColor;

    
    _quizCategoryLabel.text = [HAQuizDataManager sharedManager]._currentQuizCategoryName;
    self.navigationItem.titleView = _quizCategoryLabel;
    [_cancelButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    [_worldScoreButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    
    //cancelButton is in xib
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_cancelButton];
    
    _scoreLabel.text = [NSString stringWithFormat:@"You have Scored %lld Points",_currentScore]; // change  text here
    NSUInteger quizCategory = [HAQuizDataManager sharedManager]._currentQuizCategory;
    
    if (_currentScore > 0)
    {
        [[HAQuizDataManager sharedManager] setHighScore:_currentScore forQuizCategoryType:quizCategory];
    }
    self._hiscoresArray = [[HAQuizDataManager sharedManager] highScores];
    
    if (self._hiscoresArray.count == 0) {
        _noHighScoresLabel.hidden = NO;
    }
    
    [_hiscoreTableView reloadData];
    
    if ([[HASettings sharedManager] requiredAdDisplay]) {
        [Chartboost showInterstitial:CBLocationHomeScreen];
    }

    if ([HASettings sharedManager]._isGameCenterSupported)
    {
        NSString* leaderboardID = [[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kLeaderboardID];
        if (leaderboardID == nil) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"Gamecenter feature is enabled in \"Congiguration.plist\" file and leaderboard id is not added to category \"%@\"  ",[[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kQuizCategoryName]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
            
            return;
        }else if ([GKLocalPlayer localPlayer].authenticated &&  _currentScore > 0) {
            self.gameCenterManager = [[GameCenterManager alloc] init];
            [self.gameCenterManager setDelegate:self];
            [self.gameCenterManager authenticateLocalUser];
            
            leaderboardID = [leaderboardID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
                //sending leaderboard_id as category not the category id of quiz
            if (leaderboardID == nil || [leaderboardID isEqualToString:@""]) {
                NSLog(@"Game center enabled but category \"%@\" does not have leaderbaord id in Quiz_Categories.plist or Quiz_Categories.json", [[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kQuizCategoryName]);
            }
            else{
                
                GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] initWithPlayers:@[[GKLocalPlayer localPlayer]]];
                leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
                leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
                leaderboardRequest.identifier = [[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kLeaderboardID];
            
                [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
                    GKScore *localPlayerScore = leaderboardRequest.localPlayerScore;
                    _currentScore += localPlayerScore.value;
                    if (_currentScore != 0)
                    {
                        [self.gameCenterManager reportScore:[[NSNumber numberWithLongLong:_currentScore] longLongValue] forCategory:[[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kLeaderboardID]];
                        NSLog(@"category wise score reported");
                    }
                }];
            }
            
        } else {
            
            // The current device does not support Game Center.
            NSLog(@"game center not available");
        }
    }
    else{
        _worldScoreButton.hidden = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIColor* categoryColor = [HAUtilities colorFromHexString:[[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kCategoryColor]];
    self.navigationController.navigationBar.barTintColor = categoryColor;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation ==UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)homeAction:(id)sender
{
    [HAUtilities playTapSound];
    [self.navigationController popToRootViewControllerAnimated:YES];
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

- (IBAction)facebookShareAction:(id)sender
{
    NSString* shareString = [NSString stringWithFormat:@"I have Scored \"%lld\" Points, In \"%@\" Quiz.",_currentScore,[HAQuizDataManager sharedManager]._currentQuizCategoryName];
    NSString* applicationLink = [[HASettings sharedManager]._applicationiTunesLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *controllerSLC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controllerSLC setInitialText:shareString];
        if (applicationLink != nil && ![applicationLink isEqualToString:@""])
            [controllerSLC addURL:[NSURL URLWithString:applicationLink]];
        [self presentViewController:controllerSLC animated:YES completion:NULL];
    }
    else{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Facebook" message:@"Login to your Facebook account in device settings and try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (IBAction)twitterShareAction:(id)sender
{
    NSString* shareString = [NSString stringWithFormat:@"I have Scored \"%lld\" Points, In \"%@\" Quiz.",_currentScore,[HAQuizDataManager sharedManager]._currentQuizCategoryName];
    NSString* applicationLink = [[HASettings sharedManager]._applicationiTunesLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *controllerSLC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controllerSLC setInitialText:shareString];
        if (applicationLink != nil && ![applicationLink isEqualToString:@""])
            [controllerSLC addURL:[NSURL URLWithString:applicationLink]];
        [self presentViewController:controllerSLC animated:YES completion:NULL];
    }
    else{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Twitter" message:@"Login to your Twitter account in device settings and try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];

    }
}


- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 66.0;
    }
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_hiscoresArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* highScoreDict = [_hiscoresArray objectAtIndex:indexPath.row];
    NSString* categoryID = [highScoreDict objectForKey:kQuizCategoryId];
    NSDictionary* categoryDict = [[HAQuizDataManager sharedManager] categoryDictForCategoryId:[categoryID intValue]];
    UIColor* categoryColor = [HAUtilities colorFromHexString:[categoryDict objectForKey:kCategoryColor]];

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.textLabel.font = [UIFont fontWithName:_cancelButton.titleLabel.font.fontName size:30.0];
            cell.detailTextLabel.font = [UIFont fontWithName:_cancelButton.titleLabel.font.fontName size:30.0];
        }
        else
        {
            cell.textLabel.font = [UIFont fontWithName:_cancelButton.titleLabel.font.fontName size:16.0];
            cell.detailTextLabel.font = [UIFont fontWithName:_cancelButton.titleLabel.font.fontName size:16.0];
        }
        
        
        cell.backgroundColor = categoryColor;
    }
    
    UIColor* appTextColor = [HASettings sharedManager]._appTextColor;
    cell.textLabel.textColor = appTextColor;
    cell.detailTextLabel.textColor = appTextColor;

    cell.textLabel.text = [highScoreDict objectForKey:kQuizCategoryName];
    cell.detailTextLabel.text = [[highScoreDict objectForKey:kHighScore] stringValue];
    return cell;
}

#pragma mark - Gamecentre delegates
- (void)processGameCenterAuth: (NSError*) error
{
    if (!error) {
        NSLog(@"user authenticated");
        NSString* leaderboardID = [[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kLeaderboardID];
        leaderboardID = [leaderboardID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.gameCenterManager reportScore:[[NSNumber numberWithLongLong:_currentScore] longLongValue] forCategory:leaderboardID];
    }
}
- (void) scoreReported: (NSError*) error
{
    NSLog(@"error ------------------------ %@",error);
}
@end
