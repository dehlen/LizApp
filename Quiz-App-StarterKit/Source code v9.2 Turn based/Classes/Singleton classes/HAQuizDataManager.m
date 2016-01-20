//
//  HAQuizDataManager.m
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 11/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HAQuizDataManager.h"
#import "AppDelegate.h"
#import "SBJSON.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJSON.h"
#import "Reachability.h"
#import "GameCenterManager.h"
#import "RageIAPHelper.h"

#define kDocumentsFolderPath @"~/Documents"
#define kQuizDataFolderName @"Quiz Data"

//#define kPathForJASONQuizFolder @"~/Documents/Quiz Data/JSON_Format"
//#define kPathForPLISTQuizFolder @"~/Documents/Quiz Data/Plist_Format"
//#define kPathForPicturesFolder  @"~/Documents/Quiz Data/Pictures_Or_Videos"

#define kPurchasesPlistFilePath [@"~/Documents/purchases.plist" stringByExpandingTildeInPath]

#define kPathForJASONQuizFolder [NSString stringWithFormat:@"%@/JSON_Format",[[NSBundle mainBundle] pathForResource:@"Quiz Data" ofType:@""]]
#define kPathForPLISTQuizFolder [NSString stringWithFormat:@"%@/Plist_Format",[[NSBundle mainBundle] pathForResource:@"Quiz Data" ofType:@""]]
#define kPathForPicturesFolder  NSString stringWithFormat:@"%@/Pictures_Or_Videos",[[NSBundle mainBundle] pathForResource:@"Quiz Data" ofType:@""]]

#define kHiscorePlistFilePath @"~/Documents/Quiz_HighScore.plist"

static HAQuizDataManager* _sharedManager = nil;

@implementation HAQuizDataManager
@synthesize _currentQuizCategory;
@synthesize _currentQuizCategoryName;
@synthesize _useSourceDataFormat;
@synthesize _currentNumberOfQuestionRequiredAfterSuffle;

@synthesize _allPurchaseIdentifiers;
@synthesize _currentCategoryDict;

#pragma mark - Singleton implementation

+(HAQuizDataManager*)sharedManager
{
	@synchronized([HAQuizDataManager class])
	{
		if (!_sharedManager)
		_sharedManager = [[self alloc] init];
        
		return _sharedManager;
	}
	return nil;
}



+(id)alloc
{
	@synchronized([HAQuizDataManager class])
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
        [HASettings sharedManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged:) name:kReachabilityChangedNotification object:nil];
        Reachability* rechability = [Reachability reachabilityForInternetConnection];
        [rechability startNotifier];

        
        
        if ([[HASettings sharedManager]._dataInputFormat isEqualToString:@"json"]) {
            self._useSourceDataFormat = eHAQuizDataFormatJsonType;
            NSLog(@"json selected");
        }
        else{
            self._useSourceDataFormat = eHAQuizDataFormatPlistType;
            NSLog(@"plist selected");
        }
        [self updateQuestionsCountForAllCategories];
        [self validateAppStoredDataOnAppUpdate];

        
    }
	return self;
}


#pragma mark - high score related methods
- (void)setInitialHighscores
{
    NSString* path = [kHiscorePlistFilePath stringByExpandingTildeInPath];
    NSArray* categories = [self allQuizCategories];
    NSMutableArray* highScores = [NSMutableArray arrayWithCapacity:[categories count]];
    for (NSDictionary* dict in categories) {
        NSMutableDictionary* highScoreDict = [NSMutableDictionary dictionary];
        [highScoreDict setObject:[dict objectForKey:kQuizCategoryId] forKey:kQuizCategoryId];
        [highScoreDict setObject:[dict objectForKey:kQuizCategoryName] forKey:kQuizCategoryName];
        [highScoreDict setObject:[NSNumber numberWithLongLong:0] forKey:kHighScore];
        [highScores addObject:highScoreDict];
        [highScores writeToFile:path atomically:YES];
    }
}
- (void)setHighScore:(int64_t)inHighScore forQuizCategoryType:(NSUInteger)inCategory
{
    NSMutableArray* highScoreArray = nil;
    NSString* path = [kHiscorePlistFilePath stringByExpandingTildeInPath];

    BOOL found = NO;
    
    highScoreArray = [NSMutableArray arrayWithContentsOfFile:path];
    if ([highScoreArray count] == 0) {
        [self setInitialHighscores];
        highScoreArray = [NSMutableArray arrayWithContentsOfFile:path];
    }
        NSMutableDictionary* scoreDict = nil;
        for (scoreDict in highScoreArray )
        {
            int categoryId = [[scoreDict objectForKey:kQuizCategoryId] intValue];
            if (inCategory == categoryId) {
                found = YES;
                break;
            }
        }
        if (found) {
            int previousHighScore = [[scoreDict objectForKey:kHighScore] intValue];
            if (inHighScore > previousHighScore)
            {
                NSDictionary* categoryDict = [self categoryDictForCategoryId:inCategory];
                [scoreDict setObject:[categoryDict objectForKey:kQuizCategoryName] forKey:kQuizCategoryName];
                [scoreDict setObject:[NSNumber numberWithLongLong:inHighScore] forKey:kHighScore];
                [highScoreArray writeToFile:path atomically:YES];
            }
        }
        else{
            NSDictionary* categoryDict = [self categoryDictForCategoryId:inCategory];
            NSMutableDictionary* scoreDict1 = [NSMutableDictionary dictionary];
            [scoreDict1 setObject:[categoryDict objectForKey:kQuizCategoryName] forKey:kQuizCategoryName];
            [scoreDict1 setObject:[NSNumber numberWithLongLong:inHighScore] forKey:kHighScore];
            [scoreDict1 setObject:[categoryDict objectForKey:kQuizCategoryId] forKey:kQuizCategoryId];
            [highScoreArray addObject:scoreDict1];
            [highScoreArray writeToFile:path atomically:YES];
        }
}


- (NSDictionary* )categoryDictForCategoryId:(NSUInteger)inCategoryID
{
    NSArray* categories = [self allQuizCategories];
    for (NSDictionary* categoryDict in categories) {
        int ID = [[categoryDict objectForKey:kQuizCategoryId] intValue];
        if (ID == inCategoryID) {
            return categoryDict;
        }
    }
    NSLog(@"Category ID is not not configured properly");
    return nil;
}

- (NSUInteger)highScoreForQuizCategory:(NSUInteger)inCategory
{
    NSUInteger highScore = 0;
    NSString* path = [kHiscorePlistFilePath stringByExpandingTildeInPath];
    NSMutableArray *highScoreArray = [NSMutableArray arrayWithContentsOfFile:path];
    for (NSMutableDictionary* scoreDict in highScoreArray ) {
        NSUInteger categoryId = [[scoreDict objectForKey:kQuizCategoryId] intValue];
        if (inCategory == categoryId) {
            highScore = [[scoreDict objectForKey:kHighScore] intValue];
        }
    }
    return highScore;
}
- (NSDictionary *)highScoreDictForQuizCategory:(NSString *)inCategory
{
    NSString* path = [kHiscorePlistFilePath stringByExpandingTildeInPath];
    NSMutableArray *highScoreArray = [NSMutableArray arrayWithContentsOfFile:path];
    for (NSMutableDictionary* scoreDict in highScoreArray ) {
        NSUInteger categoryId = [[scoreDict objectForKey:kQuizCategoryId] integerValue];
        if ([inCategory integerValue] == categoryId) {
            return scoreDict;
        }
    }
    return nil;
}


- (NSMutableArray *)highScores
{
    
    NSString* path = [kHiscorePlistFilePath stringByExpandingTildeInPath];
    return [NSMutableArray arrayWithContentsOfFile:path];
}



- (void)validateAppStoredDataOnAppUpdate
{
    NSString* currentAppVersion = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString* previousAppVersion =  [[NSUserDefaults standardUserDefaults] objectForKey:@"appVersion"];
    BOOL validate = NO;
    if (previousAppVersion == nil && [self highScores].count) {
        validate = YES;
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:@"appVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (![currentAppVersion isEqualToString:previousAppVersion]) {
        validate = YES;
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:@"appVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if (validate) {
        NSArray* categories = [self allQuizCategories];
        NSString* path = [kHiscorePlistFilePath stringByExpandingTildeInPath];
        NSMutableArray* newHighScores = [[NSMutableArray alloc] initWithCapacity:categories.count];
        
        for (NSDictionary* categoryDict in categories) {
            NSDictionary* hiscoreDict = [self highScoreDictForQuizCategory:[categoryDict objectForKey:kQuizCategoryId]];
            if (hiscoreDict == nil) {
                NSMutableDictionary* highScoreDict = [NSMutableDictionary dictionary];
                [highScoreDict setObject:[categoryDict objectForKey:kQuizCategoryId] forKey:kQuizCategoryId];
                [highScoreDict setObject:[categoryDict objectForKey:kQuizCategoryName] forKey:kQuizCategoryName];
                [highScoreDict setObject:[NSNumber numberWithInt:0] forKey:kHighScore];
                [newHighScores addObject:highScoreDict];
            }
            else{
                [newHighScores addObject:hiscoreDict];
            }
        }
        [newHighScores writeToFile:path atomically:YES];
    }
}

#pragma mark - Attempted questions related methods
- (void)markQuestionRead:(NSString *)question forCategoryID:(NSString *)categoryID
{
    NSString* attemptedQuestionsFilePath = [[NSString stringWithFormat:@"~/Documents/attempted_questions_for_%@.plist",categoryID] stringByExpandingTildeInPath];
    NSMutableArray* attemptedQuestion = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:attemptedQuestionsFilePath] ) {
        attemptedQuestion = [[NSMutableArray alloc] initWithContentsOfFile:attemptedQuestionsFilePath];
    }
    
    BOOL modified = NO;
    if (attemptedQuestion == nil) {
        attemptedQuestion = [[NSMutableArray alloc] init];
        [attemptedQuestion addObject:question];
        modified = YES;
    }
    else{
        if (![attemptedQuestion containsObject:question]) {
            [attemptedQuestion addObject:question];
            modified = YES;
        }
    }
    if (modified) {
        [attemptedQuestion writeToFile:attemptedQuestionsFilePath atomically:YES];
    }
}

- (NSUInteger)attemptedQuestionsCountForCategory:(NSString *)categoryID
{
    NSString* attemptedQuestionsFilePath = [[NSString stringWithFormat:@"~/Documents/attempted_questions_for_%@.plist",categoryID] stringByExpandingTildeInPath];
    NSMutableArray* attemptedQuestion = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:attemptedQuestionsFilePath] ) {
        attemptedQuestion = [[NSMutableArray alloc] initWithContentsOfFile:attemptedQuestionsFilePath];
        return attemptedQuestion.count;
    }
    return 0;
}

- (void)updateQuestionsCountForAllCategories
{
    NSString* currentAppVersion = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString* previousAppVersion =  [[NSUserDefaults standardUserDefaults] objectForKey:@"appVersion"];
    NSUInteger categoriesCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"total_categories_count"] integerValue];
    
    NSArray* categories = [self allQuizCategories];
    if (![currentAppVersion isEqualToString:previousAppVersion] || previousAppVersion == nil || categories.count != categoriesCount)
    {
        
        for (NSDictionary* categoryDict in categories) {
            NSString* key = [NSString stringWithFormat:@"questionsCount_%@",[categoryDict objectForKey:kQuizCategoryId]];
            NSUInteger questionsCount = [self allQuestionsForCategory:[categoryDict objectForKey:kQuizCategoryId]].count;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:questionsCount] forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedLong:categories.count] forKey:@"total_categories_count"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

- (NSUInteger)questionsCountForCategoryID:(NSString *)categoryID
{
    NSString* key = [NSString stringWithFormat:@"questionsCount_%@",categoryID];
    NSUInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:key] intValue];
    return count;
}

#pragma mark - Quiz Data and path related methods 

- (NSString *)pathForJASONDataFormatWithCategory:(NSUInteger)inCategory
{
    NSString* quizFilePath = [NSString stringWithFormat:@"%@/Quiz_Category_%lu.json",[kPathForJASONQuizFolder stringByExpandingTildeInPath],(unsigned long)inCategory];
    return quizFilePath;
}

- (NSString *)pathForPLISTDataFormatWithCategory:(NSUInteger)inCategory
{
    NSString* quizFilePath = [NSString stringWithFormat:@"%@/Quiz_Category_%lu.plist",[kPathForPLISTQuizFolder stringByExpandingTildeInPath],(unsigned long)inCategory];
    return quizFilePath;
}

- (NSString *)categoryFolderPath
{
    NSString* categoryFolderPath = nil;
    if (_useSourceDataFormat == eHAQuizDataFormatJsonType)
    {
        categoryFolderPath = [kPathForJASONQuizFolder stringByExpandingTildeInPath];
    }
    else if (_useSourceDataFormat == eHAQuizDataFormatPlistType)
    {
        categoryFolderPath = [kPathForPLISTQuizFolder stringByExpandingTildeInPath];
    }
    return categoryFolderPath;
}



- (NSArray *)allQuizCategories
{
    NSString* quizCategoriesFilePath = nil;
    NSArray* categoriesArray = nil;
    if (_useSourceDataFormat == eHAQuizDataFormatJsonType)
    {
        quizCategoriesFilePath = [NSString stringWithFormat:@"%@/Quiz_Categories.json",[kPathForJASONQuizFolder stringByExpandingTildeInPath]];
        NSString* categoriesString = [[NSString alloc] initWithContentsOfFile:quizCategoriesFilePath encoding:NSUTF8StringEncoding error:nil];
        categoriesArray = [[categoriesString JSONValue] objectForKey:@"Categories"];
    }
    else if (_useSourceDataFormat == eHAQuizDataFormatPlistType)
    {
        quizCategoriesFilePath = [NSString stringWithFormat:@"%@/Quiz_Categories.plist",[kPathForPLISTQuizFolder stringByExpandingTildeInPath]];
        categoriesArray = [[NSDictionary dictionaryWithContentsOfFile:quizCategoriesFilePath] objectForKey:@"Categories"];
    }
    
    return categoriesArray;
}


- (NSArray *)quizCategories
{
    NSString* quizCategoriesFilePath = nil;
    NSArray* categoriesArray = nil;
   if (_useSourceDataFormat == eHAQuizDataFormatJsonType)
    {
        quizCategoriesFilePath = [NSString stringWithFormat:@"%@/Quiz_Categories.json",[kPathForJASONQuizFolder stringByExpandingTildeInPath]];
        NSString* categoriesString = [[NSString alloc] initWithContentsOfFile:quizCategoriesFilePath encoding:NSUTF8StringEncoding error:nil];
        categoriesArray = [[categoriesString JSONValue] objectForKey:@"Categories"];
    }
    else if (_useSourceDataFormat == eHAQuizDataFormatPlistType)
    {
        quizCategoriesFilePath = [NSString stringWithFormat:@"%@/Quiz_Categories.plist",[kPathForPLISTQuizFolder stringByExpandingTildeInPath]];
        categoriesArray = [[NSDictionary dictionaryWithContentsOfFile:quizCategoriesFilePath] objectForKey:@"Categories"];
    }

    if (![HASettings sharedManager]._isInAppPurchaseSupported) {
        return categoriesArray;
    }

    NSMutableArray* freeAndPurchasedCategories = [NSMutableArray array];
    for (NSDictionary* categoryDict in categoriesArray) {
        NSString* productIdentifier = [categoryDict objectForKey:kProductIdentifier];
        if (productIdentifier != nil)
        {
            if ([[RageIAPHelper sharedInstance] isProductPurchased:productIdentifier]) {
                [freeAndPurchasedCategories addObject:categoryDict];
            }
        }
        else{
            [freeAndPurchasedCategories addObject:categoryDict];
        }
    }
    return freeAndPurchasedCategories;
}

- (NSArray *)quizCategoriesRequirePurchase
{
    NSString* quizCategoriesFilePath = nil;
    NSArray* categoriesArray = nil;
    if (_useSourceDataFormat == eHAQuizDataFormatJsonType)
    {
        quizCategoriesFilePath = [NSString stringWithFormat:@"%@/Quiz_Categories.json",[kPathForJASONQuizFolder stringByExpandingTildeInPath]];
        NSString* categoriesString = [[NSString alloc] initWithContentsOfFile:quizCategoriesFilePath encoding:NSUTF8StringEncoding error:nil];
        categoriesArray = [[categoriesString JSONValue] objectForKey:@"Categories"];
    }
    else if (_useSourceDataFormat == eHAQuizDataFormatPlistType)
    {
        quizCategoriesFilePath = [NSString stringWithFormat:@"%@/Quiz_Categories.plist",[kPathForPLISTQuizFolder stringByExpandingTildeInPath]];
        categoriesArray = [[NSDictionary dictionaryWithContentsOfFile:quizCategoriesFilePath] objectForKey:@"Categories"];
    }
    NSMutableArray* categoriesRequirePurchase = [NSMutableArray array];
    for (NSDictionary* categoryDict in categoriesArray) {
        NSString* productIdentifier = [categoryDict valueForKey:kProductIdentifier];
        if (productIdentifier != nil) {
            if ([[RageIAPHelper sharedInstance] isProductPurchased:[categoryDict objectForKey:kProductIdentifier]] == NO)
            {
                    [categoriesRequirePurchase addObject:categoryDict];
            }
        }
    }
    return categoriesRequirePurchase;
}

- (NSArray *)allQuestionsForCategory:(NSString *)categoryID
{
    NSString* quizFilePath = nil;
    NSString* questionString = nil;
    NSArray* questionsArray = nil;
    
    if (_useSourceDataFormat == eHAQuizDataFormatJsonType)
    {
        quizFilePath = [self pathForJASONDataFormatWithCategory:categoryID.intValue];
        questionString = [[NSString alloc] initWithContentsOfFile:quizFilePath encoding:NSUTF8StringEncoding error:nil];
        questionsArray = [[questionString JSONValue] objectForKey:@"Questions"];;
        //        [self convertToproperJSON:questionsArray];
        
    }
    else if (_useSourceDataFormat == eHAQuizDataFormatPlistType)
    {
        quizFilePath = [self pathForPLISTDataFormatWithCategory:categoryID.intValue];
        questionsArray = [[NSDictionary dictionaryWithContentsOfFile:quizFilePath] objectForKey:@"Questions"];
    }
    return questionsArray;
}

- (NSArray *)questionsForCategoty:(NSUInteger)inCategory
{
    NSString* quizFilePath = nil;
    NSString* questionString = nil;
    NSArray* questionsArray = nil;

    if (_useSourceDataFormat == eHAQuizDataFormatJsonType)
    {
        quizFilePath = [self pathForJASONDataFormatWithCategory:inCategory];        
        questionString = [[NSString alloc] initWithContentsOfFile:quizFilePath encoding:NSUTF8StringEncoding error:nil];
        questionsArray = [[questionString JSONValue] objectForKey:@"Questions"];;
//        [self convertToproperJSON:questionsArray];

    }
    else if (_useSourceDataFormat == eHAQuizDataFormatPlistType)
    {
        quizFilePath = [self pathForPLISTDataFormatWithCategory:inCategory];
        questionsArray = [[NSDictionary dictionaryWithContentsOfFile:quizFilePath] objectForKey:@"Questions"];
    }
    
    if ([HASettings sharedManager]._isShuffleQuestionsEnabled)
    {
        //Shuffle questions
        NSUInteger count = [questionsArray count];
        int i;
        
        NSMutableArray *indexes = [[NSMutableArray alloc] initWithCapacity:count];
        for (i=0; i<count; i++) [indexes addObject:[NSNumber numberWithInt:i]];
        NSMutableArray *shuffle = [[NSMutableArray alloc] initWithCapacity:count];
        while ([indexes count])
        {
            int index = arc4random()%[indexes count];
            [shuffle addObject:[indexes objectAtIndex:index]];
            [indexes removeObjectAtIndex:index];
        }
        
        if (_currentNumberOfQuestionRequiredAfterSuffle > count) {
            _currentNumberOfQuestionRequiredAfterSuffle = count;
        }
        
        NSMutableArray* questions = [[NSMutableArray alloc] initWithCapacity:count];
        for (int i=0; i<_currentNumberOfQuestionRequiredAfterSuffle; i++)
        {
            int randomIndex = [[shuffle objectAtIndex:i] intValue];
            [questions addObject:[questionsArray objectAtIndex:randomIndex]];
        }

        NSLog(@"questions : %@",[questions JSONRepresentation]);
        return questions;
    }
            NSLog(@"questionsArray : %@",[questionsArray JSONRepresentation]);
    return questionsArray;
}

- (void)convertToproperJSON:(NSArray *)questions
{
    NSMutableArray* quests = [questions mutableCopy];
    for (int i=0;i<quests.count;i++)
    {
        NSMutableDictionary* quest = [[quests objectAtIndex:i] mutableCopy];
        NSMutableArray* optionsArray = [[NSMutableArray alloc] init];
        [optionsArray addObject:[quest objectForKey:@"item 0"]];
        [optionsArray addObject:[quest objectForKey:@"item 1"]];
        [optionsArray addObject:[quest objectForKey:@"item 2"]];
        [optionsArray addObject:[quest objectForKey:@"item 3"]];
        [quest setObject:optionsArray forKey:@"options"];
        
        [quest removeObjectForKey:@"item 0"];
        [quest removeObjectForKey:@"item 1"];
        [quest removeObjectForKey:@"item 2"];
        [quest removeObjectForKey:@"item 3"];
        [quests replaceObjectAtIndex:i withObject:quest];
    }
    NSLog(@"quests : %@",quests);
}

- (NSString *)pathForPictureName:(NSString *)inPictureFileName
{
    NSString* pictureFolderPath = [[[kPathForPicturesFolder stringByExpandingTildeInPath] stringByAppendingFormat:@"/Quiz_Category_%lu",(unsigned long)_currentQuizCategory];
    NSString* pictureFilePath = [pictureFolderPath stringByAppendingPathComponent:inPictureFileName];
    return pictureFilePath;
}
                                   
#pragma mark - Reachability notification
- (void)internetConnectionStatusChanged:(NSNotification *)nc
{
   if ([HAUtilities isInternetConnectionAvailable]) {
       if ([HASettings sharedManager]._isGameCenterSupported)
       {
           if ([GameCenterManager isGameCenterAvailable]) {
               GameCenterManager* gameCenterManager = [[GameCenterManager alloc] init];
               [gameCenterManager authenticateLocalUser];
           } else {
               AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
               UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Game Center is not available" preferredStyle:UIAlertControllerStyleAlert];
               UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
               [alertController addAction:ok];
               [delegate._navController presentViewController:alertController animated:YES completion:nil];
           }
       }
   }
}
                                   
                                   /*
                                    BOOL isNewer = ([currentVersion compare:oldVersion options:NSNumericSearch] == NSOrderedDescending)

                                    
                                    NSString* requiredVersion = @"1.2.0";
                                    NSString* actualVersion = @"1.1.5";
                                    
                                    if ([requiredVersion compare:actualVersion options:NSNumericSearch] == NSOrderedDescending) {
                                    // actualVersion is lower than the requiredVersion
                                    }
*/

- (NSData *)newDataForMatchData:(NSData *)inData withPoints:(int64_t)inPoints forPlayerID:(NSString *)inPlayerID
                                
{
    NSString* newStr = [[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding];
    NSMutableDictionary* quizDict  = [[[[SBJSON alloc] init] objectWithString:newStr] mutableCopy];
    [quizDict setObject:[NSNumber numberWithLongLong:inPoints] forKey:[NSString stringWithFormat:@"%@_points",inPlayerID]];
    NSString* dataString = [[[SBJSON alloc] init] stringWithObject:quizDict];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}
                                   
- (NSData *)dataForMultiplayer:(NSDictionary *)categoryDict andQuestions:(NSArray *)questions pointsObtained:(int64_t)inPoints forPlayerID:(NSString *)inPlayerID
{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *appVersion = infoDictionary[(NSString*)kCFBundleVersionKey];
    
   NSDictionary* dataPack = [NSDictionary dictionaryWithObjectsAndKeys:self._currentCategoryDict,@"category",questions,@"Questions",[NSNumber numberWithLongLong:inPoints],[NSString stringWithFormat:@"%@_points",inPlayerID],appVersion,@"v",nil];
   NSString* dataString = [[[SBJSON alloc] init] stringWithObject:dataPack];
   NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
   return data;
}
                                   
- (NSDictionary *)dataDictionaryFromPreviousParticipantMatchData:(NSData *)inData
{
    NSString* newStr = [[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding];
    NSDictionary* quizDict  = [[[SBJSON alloc] init] objectWithString:newStr];
    return quizDict;
}
@end
