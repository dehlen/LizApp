//
//  HATurnbasedFinalViewController.m
//  QUIZ_APP
//
//  Created by Pavithra Satish on 26/02/15.
//  Copyright (c) 2015 Heaven Apps. All rights reserved.
//

#import "HATurnbasedFinalViewController.h"
#import "HATurnbasedMatchHelper.h"
#import "HAQuizDataManager.h"
#import "AppDelegate.h"
#import <Social/Social.h>

@interface HATurnbasedFinalViewController ()

@end


@implementation HATurnbasedFinalViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[HAUtilities nibNameForString:nibNameOrNil] bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_homeButton];
    GKTurnBasedMatch* match = self._match;//[HATurnbasedMatchHelper sharedInstance].currentMatch;
    [_rematchButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    [_withAnotherButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    
    GKTurnBasedParticipant* thisParticipant = nil;
    GKTurnBasedParticipant* otherParticipant = nil;
    
    
    for (GKTurnBasedParticipant* participant in match.participants) {
        if ([participant.player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            thisParticipant = participant;
        }
        else{
            otherParticipant = participant;
        }
    }
    
    if (thisParticipant.matchOutcome == GKTurnBasedMatchOutcomeQuit) {
        
    }
    else if (otherParticipant.matchOutcome == GKTurnBasedMatchOutcomeQuit){
        
    }
    else{
        NSDictionary* categoryDict = nil;
        if (self._match.matchData.length > 0) {
            categoryDict = [[[HAQuizDataManager sharedManager] dataDictionaryFromPreviousParticipantMatchData:match.matchData] objectForKey:@"category"];
        }
        else{
            categoryDict = [HAQuizDataManager sharedManager]._currentCategoryDict;
        }
        
        UIColor* categoryColor = [HAUtilities colorFromHexString:[categoryDict objectForKey:kCategoryColor]];
        self.view.backgroundColor = categoryColor;
        _titleLabel.text = [categoryDict objectForKey:kQuizCategoryName];
        self.navigationItem.titleView = _titleLabel;
        
        NSDictionary* matchDict = [[HAQuizDataManager sharedManager] dataDictionaryFromPreviousParticipantMatchData:match.matchData];
        int64_t thisPlayerScore = [[matchDict objectForKey:[NSString stringWithFormat:@"%@_points",thisParticipant.player.playerID]] integerValue];

        if (match.status != GKTurnBasedMatchStatusEnded)
        {
            _rematchButton.enabled = NO;
            _matchOutcomeLabel.text = @"NOW ITS OPPONENT'S TURN!";
            _currentPlayerStatusLabel.text = [NSString stringWithFormat:@"You have scored : %ld points",(long)thisPlayerScore];
            _opponetPlayerStatusLabel.text = @"";
            _matchStatusLabel.text = @"☝️";
        }
        else{
            int64_t otherScore = [[matchDict objectForKey:[NSString stringWithFormat:@"%@_points",otherParticipant.player.playerID]] integerValue];
            
            _currentPlayerStatusLabel.text = [NSString stringWithFormat:@"You have scored : %lld points",thisPlayerScore];
            _opponetPlayerStatusLabel.text = [NSString stringWithFormat:@"%@ has scored : %lld points",otherParticipant.player.alias,otherScore];
            
            if (thisPlayerScore < otherScore)
            {
                _rematchButton.enabled = YES;
                _matchStatusLabel.text = @"👎";
                _matchOutcomeLabel.text = @"YOU LOST!";
            }
            else if (thisPlayerScore > otherScore)
            {
                _rematchButton.enabled = YES;
                _matchStatusLabel.text = @"🏆";
                _matchOutcomeLabel.text = @"YOU WON!";
            }
            else if (thisPlayerScore == otherScore){
                _rematchButton.enabled = YES;
                _matchStatusLabel.text = @"👌";
                _matchOutcomeLabel.text = @"TIED!";
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action methods
- (IBAction)facebookShareAction:(id)sender
{
    NSString* shareString = @"What a fun :) Guys try this Quiz app!";
    NSString* applicationLink = [[HASettings sharedManager]._applicationiTunesLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        UIImage* screenShot = [HAUtilities appScreenShot];
        SLComposeViewController *controllerSLC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controllerSLC setInitialText:shareString];
        [controllerSLC addImage:screenShot];
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
    NSString* shareString = @"What a fun :) Guys try this Quiz app!";
    NSString* applicationLink = [[HASettings sharedManager]._applicationiTunesLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        UIImage* screenShot = [HAUtilities appScreenShot];
        SLComposeViewController *controllerSLC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controllerSLC setInitialText:shareString];
        [controllerSLC addImage:screenShot];
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

- (IBAction)homeAction:(id)sender
{
    if (self._isPushedFromGC) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

}

- (IBAction)rematchAction:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:^{
//    }];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[HATurnbasedMatchHelper sharedInstance] rematchWithMatch:self._match];
}
- (IBAction)withAnotherAction:(id)sender
{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate._takeAnotherChallenge = YES;
    
    if (self._isPushedFromGC) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
    else{
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

@end
