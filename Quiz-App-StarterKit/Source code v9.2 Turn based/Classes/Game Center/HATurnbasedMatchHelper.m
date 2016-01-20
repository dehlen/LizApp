//
//  HATurnbasedMatchHelper.m
//  QUIZ_APP
//
//  Created by Pavithra Satish on 21/02/15.
//  Copyright (c) 2015 Heaven Apps. All rights reserved.
//

#import "HATurnbasedMatchHelper.h"
#import "HAQuizDataManager.h"
#import "GameCenterManager.h"
#import "AppDelegate.h"
#import "Reachability.h"

#define kMyWins @"MyWins"
#define kMyWinsPending @"MyWinsPending"
#define kPreviousLocalPlayerID @"previousLocalPlayerID"
#define kMatchID @"matchID"
#define kMatchIDsPlist [@"~/Documents/matchIDs.plist" stringByExpandingTildeInPath]
#define kLoseMatchIDsPlist [@"~/Documents/loose_matchIDs.plist" stringByExpandingTildeInPath]
#define kFailedSubmissionMatchesPlist [@"~/Documents/failed_submission_matches.plist" stringByExpandingTildeInPath]


@implementation HATurnbasedMatchHelper

@synthesize gameCenterAvailable;
@synthesize currentMatch;
@synthesize delegate;
@synthesize userAuthenticated;
#pragma mark Initialization

static HATurnbasedMatchHelper *sharedHelper = nil;
+ (HATurnbasedMatchHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[HATurnbasedMatchHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        self._pendingWins = [[[NSUserDefaults standardUserDefaults] objectForKey:kMyWinsPending] longLongValue];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged:) name:kReachabilityChangedNotification object:nil];
        Reachability* rechability = [Reachability reachabilityForInternetConnection];
        [rechability startNotifier];

        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated &&
        !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
        [self performUpdates];
        
    } else if (![GKLocalPlayer localPlayer].isAuthenticated &&
               userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
}

- (BOOL)resetLocalPlayerData
{
    if (![[GKLocalPlayer localPlayer].playerID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kPreviousLocalPlayerID]] && [HASettings sharedManager]._isMultiplayerSupportEnabled) {

    [[NSUserDefaults standardUserDefaults] setObject:[GKLocalPlayer localPlayer].playerID forKey:kPreviousLocalPlayerID];
    
    self._pendingWins = 0;
    self._myWins = 0;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self._myWins] forKey:kMyWins];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self._pendingWins] forKey:kMyWinsPending];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:kMatchIDsPlist]) {
        [[NSFileManager defaultManager] removeItemAtPath:kMatchIDsPlist error:
         nil];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:kFailedSubmissionMatchesPlist]) {
            [[NSFileManager defaultManager] removeItemAtPath:kFailedSubmissionMatchesPlist error:
             nil];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:kLoseMatchIDsPlist]) {
            [[NSFileManager defaultManager] removeItemAtPath:kLoseMatchIDsPlist error:
             nil];
        }
        
        return YES;
    }
    return NO;
}

#pragma mark User functions

-(UIViewController*) getRootViewController {
    return [UIApplication
            sharedApplication].keyWindow.rootViewController;
}

- (void)presentViewController:(UIViewController*)vc {
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:YES
                       completion:nil];
}


- (void)authenticateLocalUser {
    
    if (!gameCenterAvailable) return;
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewController, NSError * error)
        {
            
            if ([GKLocalPlayer localPlayer].authenticated == NO) {
                if (viewController) {
                    [self presentViewController:viewController];
                }
            }
            else{
                [[GKLocalPlayer localPlayer] registerListener:(id<GKLocalPlayerListener>)self];
                [[GKMatchmaker sharedMatchmaker] startBrowsingForNearbyPlayersWithHandler:^(GKPlayer *player, BOOL reachable) {
                    
                }];
            }
             //remove all matches
        /*    [GKTurnBasedMatch loadMatchesWithCompletionHandler:
             ^(NSArray *matches, NSError *error){
                 for (GKTurnBasedMatch *match in matches) {
                     NSLog(@"%@", match.matchID);
                     [match removeWithCompletionHandler:^(NSError *error){
                         NSLog(@"%@", error);}];
                 }}];*/
            
            //[self resetAchievements]; //uncomment this line of code to reset achievements

        }];
    } else
    {
        NSLog(@"Already authenticated!");
        [[GKLocalPlayer localPlayer] unregisterListener:(id<GKLocalPlayerListener>)self];
        [[GKLocalPlayer localPlayer] registerListener:(id<GKLocalPlayerListener>)self];
        [self performUpdates];
    }
}

- (void)performUpdates
{
    BOOL reset = [self resetLocalPlayerData]; //resets user's stored details if logged in with different user. Pending wins will be lost

    if (reset == NO)
    {
        [self checkForFraudMatchesAndSubmitAsLost];
        [self checkForResubmissionOfMatches];
        [self checkForPendingMatchesForWins];
        [[HATurnbasedMatchHelper sharedInstance] updateMyWinsCountFromLeader];
    }

}

//for testing only
-(void)resetAchievements{
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void)rematchWithMatch:(GKTurnBasedMatch *)inMatch
{    
    
    AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate showActivityIndicator];
    
    [inMatch rematchWithCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
        self.currentMatch = match;
        if (error) {
            NSLog(@"error rematch : %@",error.localizedDescription);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"Error occured, please try again" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [appdelegate._navController presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            NSLog(@"existing Match");
            [delegate enterNewGame:match];
        }
        [appdelegate hideActivityIndicator];
    }];
}

- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController showExistingMatches:(BOOL)show{
    if (!gameCenterAvailable) return;
    self.presentingViewController = viewController;
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    GKTurnBasedMatchmakerViewController *mmvc =
    [[GKTurnBasedMatchmakerViewController alloc]
     initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = show;
    
    [self.presentingViewController presentViewController:mmvc animated:YES completion:^{
        
    }];
}

#pragma mark - GKEventLister
- (void)player:(GKPlayer *)player didAcceptInvite:(GKInvite *)invite
{
    NSLog(@"Invitation accepted");
}


- (void)player:(GKPlayer *)player didRequestMatchWithRecipients:(NSArray *)recipientPlayers
{
    
}
- (void)player:(GKPlayer *)player didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite
{
    //......insert some cleanup code for managing view controllers
    GKMatchRequest *match = [[GKMatchRequest alloc]init];
    match.playersToInvite = playerIDsToInvite;
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc]initWithMatchRequest:match];
    mmvc.matchmakerDelegate = self;
    [[[[[UIApplication sharedApplication]delegate]window]rootViewController]presentViewController:mmvc animated:YES completion:nil];
}

- (void)player:(GKPlayer *)player matchEnded:(GKTurnBasedMatch *)match
{
    NSLog(@"Game has ended");
    [self checkForPendingMatchesForWins];
}


- (void)player:(GKPlayer *)player didRequestMatchWithOtherPlayers:(NSArray *)playersToInvite
{
    NSLog(@"didRequestMatchWithOtherPlayers");
    [self.presentingViewController
     dismissViewControllerAnimated:YES completion:^{
         
     }];
    GKMatchRequest *request =
    [[GKMatchRequest alloc] init];
    request.recipients = playersToInvite;
    request.maxPlayers = 2;
    request.minPlayers = 2;
    GKTurnBasedMatchmakerViewController *viewController =
    [[GKTurnBasedMatchmakerViewController alloc]
     initWithMatchRequest:request];
    viewController.showExistingMatches = NO;
    viewController.turnBasedMatchmakerDelegate = self;
    [self.presentingViewController
     presentViewController:viewController animated:YES completion:^{
         
     }];
}

- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive
{
    [self.presentingViewController
     dismissViewControllerAnimated:YES completion:^{
         
     }];
    if (match == nil) {
        NSLog(@"match is nilllllllllll");
        return;
    }
    
    self.currentMatch = match;
    GKTurnBasedParticipant *firstParticipant =
    [match.participants objectAtIndex:0];
    if (firstParticipant.lastTurnDate == NULL)
    {
        NSLog(@"existing Match");
        [delegate enterNewGame:match];
    }
    else{
        
        NSString* statusString = nil;
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
            
            statusString = @"You have Quit this match";
        }
        else if (otherParticipant.matchOutcome == GKTurnBasedMatchOutcomeQuit)
        {
            statusString = @"Opponent has Quit this match";
        }
        else if (otherParticipant.status ==  GKTurnBasedParticipantStatusDeclined)
        {
            statusString = @"Opponent has Declined your challenge";
        }
        if (statusString == nil) {
            if ([match.currentParticipant.player.playerID
                 isEqualToString:[GKLocalPlayer localPlayer].playerID])
            {
                [delegate takeTurn:match];
            } else
            {
                [delegate layoutMatch:match];
            }
        }
        else{
            AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Match status\n" message:statusString preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [appdelegate._navController presentViewController:alertController animated:YES completion:nil];
            
        }
    }
    
   /* [self.presentingViewController
     dismissViewControllerAnimated:YES completion:^{
         
     }];

    NSLog(@"Turn has happened");
    if ([match.matchID isEqualToString:currentMatch.matchID]) {
        if ([match.currentParticipant.player.playerID
             isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // it's the current match and it's our turn now
            self.currentMatch = match;
            [delegate takeTurn:match];
        } else {
            // it's the current match, but it's someone else's turn
            self.currentMatch = match;
            [delegate layoutMatch:match];
        }
    } else {
        if ([match.currentParticipant.player.playerID
             isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // it's not the current match and it's our turn now
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showActivityIndicator];

            if (![HASettings sharedManager]._isGameScreenVisible)
            {
                self.currentMatch = match;
                [delegate takeTurn:match];
            }
            [appDelegate hideActivityIndicator];
        } else {
            // it's the not current match, and it's someone else's
            // turn
        }
    }*/
}

- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive
{
    NSLog(@"match recieved");
}

- (void)player:(GKPlayer *)player wantsToQuitMatch:(GKTurnBasedMatch *)match
{
    NSUInteger currentIndex =
    [match.participants indexOfObject:match.currentParticipant];
    GKTurnBasedParticipant *part = nil;
    
    for (int i = 0; i < [match.participants count]; i++) {
        part = [match.participants objectAtIndex:
                (currentIndex + 1 + i) % match.participants.count];
        if (part.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            break;
        }
    }
    NSLog(@"playerquitforMatch, %@, %@",
          match, match.currentParticipant);
    if (part) {
        [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:[NSArray arrayWithObject:part] turnTimeout:GKTurnTimeoutNone matchData:match.matchData completionHandler:^(NSError *error) {
            
        }];
    }

}

#pragma mark GKTurnBasedMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self.presentingViewController
     dismissViewControllerAnimated:YES completion:^{
         
     }];

}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self.presentingViewController
     dismissViewControllerAnimated:YES completion:^{
         
     }];

}


/*- (void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
                            didFindMatch:(GKTurnBasedMatch *)match {
    [self.presentingViewController
     dismissViewControllerAnimated:YES completion:^{
         
     }];
    if (match == nil) {
        NSLog(@"match is nilllllllllll");
        return;
    }
    
    self.currentMatch = match;
    GKTurnBasedParticipant *firstParticipant =
    [match.participants objectAtIndex:0];
    if (firstParticipant.lastTurnDate == NULL)
    {
        NSLog(@"existing Match");
        [delegate enterNewGame:match];
    }
    else{
        
        NSString* statusString = nil;
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
            
            statusString = @"You have Quit this match";
        }
        else if (otherParticipant.matchOutcome == GKTurnBasedMatchOutcomeQuit)
        {
            statusString = @"Opponent has Quit this match";
        }
        else if (otherParticipant.status ==  GKTurnBasedParticipantStatusDeclined)
        {
            statusString = @"Opponent has Declined your challenge";
        }
        
        if (statusString == nil) {
            if ([match.currentParticipant.player.playerID
                 isEqualToString:[GKLocalPlayer localPlayer].playerID])
            {
                [delegate takeTurn:match];
            } else
            {
                [delegate layoutMatch:match];
            }
        }
        else{
            AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Match status\n" message:statusString preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [appdelegate._navController presentViewController:alertController animated:YES completion:nil];

        }
    }
}*/

-(void)turnBasedMatchmakerViewControllerWasCancelled:
(GKTurnBasedMatchmakerViewController *)viewController {
    [self.presentingViewController
     dismissViewControllerAnimated:YES completion:^{
         [self.presentingViewController.navigationController popViewControllerAnimated:YES];
     }];
    NSLog(@"has cancelled");
}

-(void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
                        didFailWithError:(NSError *)error {
    [self.presentingViewController
     dismissViewControllerAnimated:YES completion:^{
         
     }];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}


/*-(void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
                      playerQuitForMatch:(GKTurnBasedMatch *)match {
    
    NSUInteger currentIndex =
    [match.participants indexOfObject:match.currentParticipant];
    GKTurnBasedParticipant *part = nil;
    
    for (int i = 0; i < [match.participants count]; i++) {
        part = [match.participants objectAtIndex:
                (currentIndex + 1 + i) % match.participants.count];
        if (part.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            break;
        }
    }
    NSLog(@"playerquitforMatch, %@, %@",
          match, match.currentParticipant);
    if (part) {
        [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:[NSArray arrayWithObject:part] turnTimeout:GKTurnTimeoutNone matchData:match.matchData completionHandler:^(NSError *error) {
            
        }];
    }
}*/

- (void)updateMyWinsCountFromLeader
{
    
        GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] initWithPlayers:@[[GKLocalPlayer localPlayer]]];
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.identifier = [HASettings sharedManager]._totalWinsLeaderboardID;
        
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
            if (scores.count == 0 || error)
            {
                
            }
            else{
                GKScore* score = [scores firstObject];
                if (score.value > self._myWins) {
                    self._myWins = score.value;
                    //update wins
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self._myWins] forKey:kMyWins];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSLog(@"updated wins : %lld",self._myWins);
                }
            }
        }];
}

- (void)checkForPendingMatchesForWins
{
    NSArray* matchIDs = [[NSArray alloc] initWithContentsOfFile:kMatchIDsPlist];
    for (NSString* matchID in matchIDs) {
        [GKTurnBasedMatch loadMatchWithID:matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
            if (error) {
                NSLog(@"unable to fetch match ID : %@",matchID);
            }
            else if (match == nil)
            {
                [self removeMatchID:match.matchID];
            }
            else{
                NSArray* participants = match.participants;
                GKTurnBasedParticipant* localPlayer = nil;
                for (GKTurnBasedParticipant* participant in participants) {
                    if ([participant.player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID ]) {
                        localPlayer = participant; break;
                    }
                }

                if (localPlayer.matchOutcome == GKTurnBasedMatchOutcomeWon)
                {
                    self._pendingWins++;
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self._pendingWins] forKey:kMyWinsPending];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self removeMatchID:match.matchID];
                    [self reportPendingWins];
                    NSLog(@"----won match id removed : %@",match.matchID);
                }
                else if (localPlayer.matchOutcome == GKTurnBasedMatchOutcomeLost || localPlayer.matchOutcome == GKTurnBasedMatchOutcomeTied || localPlayer.matchOutcome == GKTurnBasedMatchOutcomeQuit || localPlayer.matchOutcome == GKTurnBasedMatchOutcomeTimeExpired)
                {
                    [self removeMatchID:match.matchID];
                    NSLog(@"----tied match id removed : %@",match.matchID);
                }

            }
        }];
    }
}

- (void)reportPendingWins
{
    if (self._pendingWins > 0) {
        GKScore* score = [[GKScore alloc] initWithLeaderboardIdentifier:[HASettings sharedManager]._totalWinsLeaderboardID];
        if (self._pendingWins > 0) {
            score.value = self._myWins + self._pendingWins;
        }
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"error in posting wins, will try later");
                self._pendingWins +=1;
            }
            else{
                self._pendingWins = 0;
                self._myWins +=1;
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self._myWins] forKey:kMyWins];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self._pendingWins] forKey:kMyWinsPending];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //update achievements
                [self updateAchievements];

            }
        }];
    }
}

- (void)iWon
{
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        self._pendingWins++;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self._pendingWins] forKey:kMyWinsPending];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    GKScore* score = [[GKScore alloc] initWithLeaderboardIdentifier:[HASettings sharedManager]._totalWinsLeaderboardID];
    if (self._pendingWins > 0) {
        score.value = self._myWins + 1 + self._pendingWins;
    }
    else{
        score.value = self._myWins + 1;
    }
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"error in posting wins, will try later");
            self._pendingWins +=1;
        }
        else{
            self._pendingWins = 0;
            self._myWins +=1;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self._myWins] forKey:kMyWins];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self._pendingWins] forKey:kMyWinsPending];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //update achievements
            [self updateAchievements];
        }
    }];
}

- (void)updateAchievements
{
    
    NSArray* achievements = [HASettings sharedManager]._achievementsForWins;
    NSDictionary* firstAchievementDict = nil;
    NSMutableArray* postAchivements = [[NSMutableArray alloc] init];
    if (achievements.count) {
        firstAchievementDict = [achievements objectAtIndex:0];
    }

    for (int i=0;i<achievements.count;i++)
    {
        NSDictionary* achievementDict = [achievements objectAtIndex:i];
        NSUInteger requiredPoints = [[achievementDict objectForKey:kWins] integerValue];
        if (self._myWins >= requiredPoints && self._myWins >= [[firstAchievementDict objectForKey:kWins] integerValue]) {
            GKAchievement* achievement = [[GKAchievement alloc] initWithIdentifier:[[achievementDict objectForKey:kAchievementID] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] player:[GKLocalPlayer localPlayer]];
            achievement.percentComplete = 100.0;
            [postAchivements addObject:achievement];
        }
    }
    
    if (postAchivements.count) {
        NSLog(@"posting achievements : %@",[postAchivements description]);
        [GKAchievement reportAchievements:postAchivements withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"error : %@",error);
            }
            else{
                NSLog(@"achievement posted");
            }
        }];
    }
}

- (void)addMatchID:(NSString *)inMatchID
{
    NSMutableArray* matchIDs = [[NSMutableArray alloc] initWithContentsOfFile:kMatchIDsPlist];
    if (matchIDs == nil) {
        matchIDs = [[NSMutableArray alloc] init];
        [matchIDs addObject:inMatchID];
    }
    else{
        [matchIDs addObject:inMatchID];
    }
    [matchIDs writeToFile:kMatchIDsPlist atomically:YES];
}

- (void)removeMatchID:(NSString *)inMatchID //remove stored id and update score.
{
    NSMutableArray* matchIDs = [[NSMutableArray alloc] initWithContentsOfFile:kMatchIDsPlist];
    if (matchIDs != nil) {
        [matchIDs removeObject:inMatchID];
        [matchIDs writeToFile:kMatchIDsPlist atomically:YES];
    }
}

#pragma mark - Achievement
- (GKAchievement *)achievementForWins:(int64_t)inWins forPlayer:(GKPlayer *)inPlayer
{
    
    NSArray* achievementIDs = [HASettings sharedManager]._achievementsForWins;
    NSString* achievementID = nil;
    
    for (NSDictionary* achievementDict in achievementIDs) {
        if (inWins >= [[achievementDict objectForKey:@"Wins"] unsignedIntegerValue])
        {
            achievementID = [achievementDict objectForKey:@"Achievement ID"];
        }
    }
    
    if (achievementID == nil) {
        return nil;
    }
    GKAchievement* achievement = [[GKAchievement alloc] initWithIdentifier:achievementID player:inPlayer];
    achievement.percentComplete = 100.0;
    return achievement;
}

#pragma mark - Cheat handling methods
- (void)saveCurrentMatchInLoseList
{
    NSMutableArray* matchIDs = [[NSMutableArray alloc] initWithContentsOfFile:kLoseMatchIDsPlist];
    if (matchIDs == nil || matchIDs.count == 0) {
        matchIDs = [[NSMutableArray alloc] init];
        [matchIDs addObject:self.currentMatch.matchID];
    }
    [matchIDs writeToFile:kLoseMatchIDsPlist atomically:YES];
}

- (void)removeMatchIDMarkedAsLost:(NSString *)inMatchID
{
    NSMutableArray* matchIDs = [[NSMutableArray alloc] initWithContentsOfFile:kLoseMatchIDsPlist];
    if ([matchIDs containsObject:inMatchID]) {
        [matchIDs removeObject:inMatchID];
        [matchIDs writeToFile:kLoseMatchIDsPlist atomically:YES];
    }
}

- (void)checkForFraudMatchesAndSubmitAsLost
{
    NSMutableArray* matchIDs = [[NSMutableArray alloc] initWithContentsOfFile:kLoseMatchIDsPlist];
    
    for (NSString* matchID in matchIDs) {
        [GKTurnBasedMatch loadMatchWithID:matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
            if (error) {
                NSLog(@"lets try next time");
            }
            else if (match == nil)
            {
                [self removeMatchIDMarkedAsLost:match.matchID];
            }
            else{
                GKTurnBasedParticipant* localPlayer;
                GKTurnBasedParticipant* otherPlayer;
                for (GKTurnBasedParticipant* participant in match.participants) {
                    if ([participant.player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                        localPlayer = participant;
                    }
                    else{
                        otherPlayer = participant;
                    }
                }
                
                localPlayer.matchOutcome = GKTurnBasedMatchOutcomeLost;
                otherPlayer.matchOutcome = GKTurnBasedMatchOutcomeWon;
                [match endMatchInTurnWithMatchData:match.matchData completionHandler:^(NSError *error) {
                    if (error) {
                        if (error.code == 24) //invalid match state
                        {
                            [self removeMatchIDMarkedAsLost:match.matchID];
                        }
                    }
                    else{
                        [self removeMatchIDMarkedAsLost:match.matchID];
                    }
                    NSLog(@"match lost");
                }];
            }
        }];
    }
}

#pragma mark - Fails submissions handle
- (void)saveCurrentMatchInResubmissionList
{
    NSMutableArray* matches = [[NSMutableArray alloc] initWithContentsOfFile:kFailedSubmissionMatchesPlist];
    if (matches.count == 0) {
        matches = [[NSMutableArray alloc] init];
    }
    
    NSMutableDictionary* savedMatchDict = [[NSMutableDictionary alloc] init];
    [savedMatchDict setObject:self.currentMatch.matchID forKey:kMatchID];
    [savedMatchDict setObject:[NSNumber numberWithLongLong:self._currentMatchScore] forKey:kScore];
    [matches addObject:savedMatchDict];
    [matches writeToFile:kFailedSubmissionMatchesPlist atomically:YES];
}

- (void)removeFromResubmittedList:(NSString *)inMatchID
{
    NSMutableArray* matches = [[NSMutableArray alloc] initWithContentsOfFile:kFailedSubmissionMatchesPlist];
    for (NSDictionary* matchDict in matches ) {
        if ([[matchDict objectForKey:kMatchID] isEqualToString:inMatchID])
        {
            [matches removeObject:matchDict];
            [matches writeToFile:kFailedSubmissionMatchesPlist atomically:YES];
            break;
        }
    }
}

- (void)checkForResubmissionOfMatches
{
    
    NSMutableArray* matches = [[NSMutableArray alloc] initWithContentsOfFile:kFailedSubmissionMatchesPlist];
    for (NSDictionary* faileMatchDict in matches) {
        NSString* matchID = [faileMatchDict objectForKey:kMatchID];
        [GKTurnBasedMatch loadMatchWithID:matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error)
        {
            if (error) {
                
                if (error.code == 24) //invalid match state
                {
                    NSLog(@"Invalid match state remove match from cache : %@",matchID);
                    [self removeFromResubmittedList:match.matchID];
                }

            }
            else if (match == nil)
            {
                
            }
            else
            {
                int64_t myScore = [[faileMatchDict objectForKey:kScore] longLongValue];
                NSLog(@"failed submission match store score : %lld",myScore);
                GKTurnBasedParticipant* player1;
                GKTurnBasedParticipant* player2;
                
                for (GKTurnBasedParticipant* participant in match.participants) {
                    if ([participant.player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                        player1 = participant;
                    }
                    else{
                        player2 = participant;
                    }
                }
                
                NSData *data = [[HAQuizDataManager sharedManager] newDataForMatchData:match.matchData withPoints:(NSInteger)myScore forPlayerID:match.currentParticipant.player.playerID];
                
                NSDictionary* quizDict = [[HAQuizDataManager sharedManager] dataDictionaryFromPreviousParticipantMatchData:match.matchData];
                NSInteger otherScore = [[quizDict objectForKey:[NSString stringWithFormat:@"%@_points",player2.player.playerID]] integerValue];
                
                
                if (myScore < otherScore)
                {
                    player1.matchOutcome = GKTurnBasedMatchOutcomeLost;
                    player2.matchOutcome = GKTurnBasedMatchOutcomeWon;
                }
                else if (myScore == otherScore)
                {
                    player1.matchOutcome =  GKTurnBasedMatchOutcomeTied;
                    player2.matchOutcome = GKTurnBasedMatchOutcomeTied;
                }
                else
                {
                    [self iWon];
                    player1.matchOutcome = GKTurnBasedMatchOutcomeWon;
                    player2.matchOutcome = GKTurnBasedMatchOutcomeLost;
                }
                [match endMatchInTurnWithMatchData:data scores:@[] achievements:@[] completionHandler:^(NSError *error)
                 {
                     if (error) //unable to end match
                     {
                         if (error.code == 24) //invalid match state
                         {
                             NSLog(@"checkForResubmissionOfMatches: Invalid match state remove match from cache : %@",matchID);
                             [self removeFromResubmittedList:match.matchID];
                         }
                         NSLog(@"Failed to resubmit match ID: %@",match.matchID);
                     }
                     else
                     {
                         [self removeFromResubmittedList:match.matchID];
                     }
                 }];
            }
        }];
    }
}

#pragma mark - NEtwork available notification
- (void)internetConnectionStatusChanged:(NSNotification *)nc
{
    if ([HAUtilities isInternetConnectionAvailable]) {
        if ([HASettings sharedManager]._isMultiplayerSupportEnabled || [HASettings sharedManager]._isGameCenterSupported) {
            //[self authenticateLocalUser];
            [self performUpdates];
        }
    }
}

@end
