//
//  HASettings.m
//  QUIZ_APP
//
//  Created by Pavithra Satish on 27/12/14.
//  Copyright (c) 2014 Heaven Apps. All rights reserved.
//

#import "HASettings.h"
#import "HAQuizDataManager.h"
#import "AppDelegate.h"

static HASettings* _sharedManager = nil;

@implementation HASettings
#pragma mark - Singleton implementation

+ (HASettings *)sharedManager
{
    @synchronized([HASettings class])
    {
        if (!_sharedManager)
            _sharedManager = [[self alloc] init];
        
        return _sharedManager;
    }
    return nil;
}

+(id)alloc
{
    @synchronized([HASettings class])
    {
        NSAssert(_sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

-(id)init {
    self = [super init];
    if (self != nil)
    {
        NSString* configurationsFilesPath = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
        NSDictionary* configDict = [NSDictionary dictionaryWithContentsOfFile:configurationsFilesPath];
        NSDictionary* featuresDict = [configDict objectForKey:FeaturesSettings];
        NSDictionary* interfaceDict = [configDict objectForKey:InterfaceSettings];

//Features settings
        self._isAdSupported = [[featuresDict objectForKey:EnableAdsSupport] boolValue];
        self._isGameCenterSupported = [[featuresDict objectForKey:EnableGameCenter] boolValue];
        self._isInAppPurchaseSupported = [[featuresDict objectForKey:EnableInAppPurchase] boolValue];
        self._isShuffleAnswersEnabled = [[featuresDict objectForKey:EnableShuffleAnswers] boolValue];
        self._isShuffleQuestionsEnabled = [[featuresDict objectForKey:EnableShuffleQuestions] boolValue];
        self._isHighlightCorrectAnswerEnabled = [[featuresDict objectForKey:HighlighCorrectAnswerIfansweredWrong] boolValue];
        self._isParentalGateEnabled = [[featuresDict objectForKey:EnableParentalGate] boolValue];
        self._isTimerbasedScoreEnabled = [[featuresDict objectForKey:EnableTimerBasedScore] boolValue];
        self._removeAdsProdcutIdentifier = [featuresDict objectForKey:RemoveAdsProductIdentifier];
        self._dataInputFormat = [featuresDict objectForKey:DataInputFormat];
        self._applicationiTunesLink = [featuresDict objectForKey:ApplicationiTunesLink];
        self._fullPointsBeforeSeconds = [[featuresDict objectForKeyedSubscript:FullPointsBeforeSeconds] unsignedIntegerValue];
        self._isMultiplayerSupportEnabled = [[featuresDict objectForKey:EnableMultiplayerSupport] boolValue];
        self._totalWinsLeaderboardID = [featuresDict objectForKey:TotalWinsLeaderboardID];
        self._achievementsForWins = [featuresDict objectForKey:AchievementsForWins];
        
//Interface settings
        
        self._appTextColor = [HAUtilities colorFromHexString:[interfaceDict objectForKey:AppTextColor]];
        self._menuScreenTittle = [interfaceDict objectForKey:MenuScreenTitle];
        self._categoriesScreenTitle = [interfaceDict objectForKey:CategoriesScreenTitle];
        self._aboutScreenTitle = [interfaceDict objectForKey:AboutScreenTitle];
        self._aboutScreenTextOrURL = [interfaceDict objectForKey:AboutTextOrURL];
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:kSoundsOnOff] == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kSoundsOnOff];
        }
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:kShowExplanation] == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kShowExplanation];
        }
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:kAdsTurnedOff] == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kAdsTurnedOff];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];

        
        self._isSoundsOn = [[[NSUserDefaults standardUserDefaults] objectForKey:kSoundsOnOff] boolValue];
        self._isAdsTurnedOff = [[[NSUserDefaults standardUserDefaults] objectForKey:kAdsTurnedOff] boolValue];
        self._showExplanation = [[[NSUserDefaults standardUserDefaults] objectForKey:kShowExplanation] boolValue];
        
    }
    return self;
}

- (void)setSoundsEnabled:(BOOL)isOn
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isOn] forKey:kSoundsOnOff];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self._isSoundsOn = isOn;

}

- (void)setShowExplanation:(BOOL)isOn
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isOn] forKey:kShowExplanation];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self._showExplanation = isOn;
}


- (void)setAdsTurnedOff:(BOOL)isOn
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isOn] forKey:kAdsTurnedOff];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self._isAdsTurnedOff = isOn;
}

- (BOOL)requiredAdDisplay
{
    if (self._isAdSupported) {
        return !self._isAdsTurnedOff;
    }
    return NO;
}

- (BOOL)validateSettings
{
    if (self._isAdSupported && (self._removeAdsProdcutIdentifier == nil || [self._removeAdsProdcutIdentifier isEqualToString:@""]))
    {
        self._isAdSupported = NO;
        
        AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Developer alert" message:@"You have enabled ads by setting value YES to property \"Enable Ads Support\" in \"Configuration.plist->Features Settings\" and not specified product identifier for removing ads through InApp purchase for property \"Remove Ads Product Identifier\". If you are not willing to support ads set NO to property \"Enable Ads Support\" in \"Configuration.plist->Features Settings\". Ads are turned off automatically." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [appdelegate._navController presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    
    if (self._isGameCenterSupported) {
        NSArray* allcategories = [[HAQuizDataManager sharedManager] allQuizCategories];
        for (NSDictionary* category in allcategories) {
            if ([category valueForKey:kLeaderboardID] == nil || [[category valueForKey:kLeaderboardID] isEqualToString:@""]) {
                
                AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Developer alert" message:[NSString stringWithFormat:@"You have enabled ads by setting value YES to property \"Enable Game Center\" in \"Configuration.plist->Features Settings\" and not specified \"leaderboardID\" for category \"%@\". If you are not willing to support game center please turn off from the category node from \"Quiz_Categories.plist or json\" file",[category objectForKey:kQuizCategoryName]] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [appdelegate._navController presentViewController:alertController animated:YES completion:nil];
                return NO;
            }
        }
    }
    
    if (self._applicationiTunesLink == nil || [self._applicationiTunesLink isEqualToString:@""])
    {
        
        AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Developer alert" message:@"Add iTune's link of this app for property at \"Configuration.plist->Features Settings->ApplicationiTunesLink\". You can find this link iTunes connect once you have created the app. This link will be shared on social n/ws along with score while sharing score." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [appdelegate._navController presentViewController:alertController animated:YES completion:nil];
        return NO;
    }

    return YES;
}
@end
