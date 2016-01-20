//
//  HATurnbasedMatchHelper.h
//  QUIZ_APP
//
//  Created by Pavithra Satish on 21/02/15.
//  Copyright (c) 2015 Heaven Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kSaveMatchIDsPlistForContinuation [@"~/Documents/savedMatchIDsForContinuation.plist" stringByExpandingTildeInPath]

@protocol HATurnbasedMatchHelperDelegate
- (void)enterNewGame:(GKTurnBasedMatch *)match;
- (void)layoutMatch:(GKTurnBasedMatch *)match;
- (void)takeTurn:(GKTurnBasedMatch *)match;
//- (void)recieveEndGame:(GKTurnBasedMatch *)match; //handled in this class
@end


@interface HATurnbasedMatchHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate,GKMatchmakerViewControllerDelegate , GKChallengeListener, GKLocalPlayerListener, GKInviteEventListener, GKTurnBasedEventListener>
{
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    id <HATurnbasedMatchHelperDelegate> delegate;
    
}
@property (nonatomic, strong) UIViewController *presentingViewController;
@property (nonatomic, assign) int64_t _myWins;
@property (nonatomic, assign) int64_t _pendingWins;
@property (assign, nonatomic) BOOL userAuthenticated;
@property (assign, readonly) BOOL gameCenterAvailable;
@property (nonatomic,strong) GKTurnBasedMatch * currentMatch;
@property (nonatomic, strong) id <HATurnbasedMatchHelperDelegate> delegate;

@property (nonatomic, assign) int64_t _currentMatchScore;
@property (nonatomic, assign) BOOL _saveToLoseList;



+ (HATurnbasedMatchHelper *)sharedInstance;
- (void)authenticateLocalUser;

- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController showExistingMatches:(BOOL)show;
- (GKAchievement *)achievementForWins:(int64_t)inWins forPlayer:(GKPlayer *)inPlayer;
- (void)presentViewController:(UIViewController*)vc;
- (void)updateMyWinsCountFromLeader;
- (void)iWon;
- (void)addMatchID:(NSString *)inMatchID;
- (void)removeMatchID:(NSString *)inMatchID;
- (void)checkForPendingMatchesForWins;
- (BOOL)resetLocalPlayerData;
- (void)updateAchievements;
- (void)rematchWithMatch:(GKTurnBasedMatch *)inMatch;

//cheat handling
- (void)saveCurrentMatchInLoseList;
- (void)removeMatchIDMarkedAsLost:(NSString *)inMatchID;
- (void)checkForFraudMatchesAndSubmitAsLost;

//failed submissions
- (void)saveCurrentMatchInResubmissionList;
- (void)removeFromResubmittedList:(NSString *)inMatchID;
- (void)checkForResubmissionOfMatches;
@end
