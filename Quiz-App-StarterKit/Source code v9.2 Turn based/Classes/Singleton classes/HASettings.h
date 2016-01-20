//
//  HASettings.h
//  QUIZ_APP
//
//  Created by Pavithra Satish on 27/12/14.
//  Copyright (c) 2014 Heaven Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Interface related Keys

#define InterfaceSettings @"Interface Settings"
#define BoldAppFont @"Bold App Font"
#define NonBoldAppFont @"Non Bold App Font"
#define BoldTextInHEX @"Bold Text Color In HEX"
#define NonBoldTextColorInHEX @"Non Bold Text Color In HEX"
#define MenuScreenTitle @"Menu Screen Title"
#define CategoriesScreenTitle @"Categories Screen Title"
#define AboutScreenTitle @"About Screen Title"
#define AboutTextOrURL @"About Text Or URL"
#define AppTextColor @"App Text Color"

#pragma mark - Feature related Keys
#define FeaturesSettings @"Features Settings"
#define EnableAdsSupport @"Enable Ads Support"
#define RemoveAdsProductIdentifier @"Remove Ads Product Identifier"
#define EnableGameCenter @"Enable Game Center"
#define EnableInAppPurchase @"Enable In App Purchase"
#define DataInputFormat @"Data Input Format"
#define EnableShuffleQuestions @"Enable Shuffle Questions"
#define EnableShuffleAnswers @"Enable Shuffle Answers"
#define HighlighCorrectAnswerIfansweredWrong @"Highlight Correct Answer If answered Wrong"
#define EnableTimerBasedScore @"Enable Timer Based Score"
#define EnableParentalGate @"Enable Parental Gate"
#define ApplicationiTunesLink @"ApplicationiTunesLink"
#define FullPointsBeforeSeconds @"Full Points Before Seconds"
#define EnableMultiplayerSupport @"Enable Multiplayer Support"
#define TotalWinsLeaderboardID @"Total Wins Leaderboard ID"
#define AchievementsForWins @"Achievements For Wins"


#pragma mark - Other keys
#define kSoundsOnOff @"SoundsOnOff"
#define kAdsTurnedOff @"AdsTurnedOff"
#define kShowExplanation @"ShowExplanation"
#define kAchievementID @"Achievement ID"
#define kWins @"Wins"



@interface HASettings : NSObject
//Features Settings
@property (nonatomic, assign) BOOL _isAdSupported;
@property (nonatomic, assign) BOOL _isGameCenterSupported;
@property (nonatomic, assign) BOOL _isInAppPurchaseSupported;
@property (nonatomic, assign) BOOL _isShuffleAnswersEnabled;
@property (nonatomic, assign) BOOL _isShuffleQuestionsEnabled;
@property (nonatomic, assign) BOOL _isHighlightCorrectAnswerEnabled;
@property (nonatomic, assign) BOOL _isTimerbasedScoreEnabled;
@property (nonatomic, assign) BOOL _isParentalGateEnabled;
@property (nonatomic, strong) NSString* _removeAdsProdcutIdentifier;
@property (nonatomic, strong) NSString* _dataInputFormat;
@property (nonatomic, strong) NSString* _applicationiTunesLink;
@property (nonatomic, assign) NSUInteger _fullPointsBeforeSeconds;
@property (nonatomic, assign) NSString* _totalWinsLeaderboardID;
@property (nonatomic, assign) BOOL _isMultiplayerSupportEnabled;
@property (nonatomic, strong) NSArray* _achievementsForWins;


@property (nonatomic, strong) NSString* _menuScreenTittle;
@property (nonatomic, strong) NSString* _categoriesScreenTitle;
@property (nonatomic, strong) NSString* _aboutScreenTitle;
@property (nonatomic, strong) NSString* _aboutScreenTextOrURL;
@property (nonatomic, strong) UIColor* _appTextColor;

@property (nonatomic, assign) BOOL _isSoundsOn;
@property (nonatomic, assign) BOOL _isAdsTurnedOff;
@property (nonatomic, assign) BOOL _showExplanation;
@property (nonatomic, assign) BOOL _isGameScreenVisible;
@property (nonatomic, assign) BOOL _isMultiplayerGame;

+ (HASettings *)sharedManager;
- (BOOL)requiredAdDisplay;
- (void)setSoundsEnabled:(BOOL)isOn;
- (void)setAdsTurnedOff:(BOOL)isOn;
- (void)setShowExplanation:(BOOL)isOn;
- (BOOL)validateSettings;
@end
