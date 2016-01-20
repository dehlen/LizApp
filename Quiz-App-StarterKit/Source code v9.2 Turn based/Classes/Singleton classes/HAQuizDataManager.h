//
//  HAQuizDataManager.h
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 11/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum HAQuestionType
{
    eHAQuestionTextType = 1,
    eHAQuestionPictureType = 2,
    eHAQuestionVideoType = 3,
    eHAQuestionTrueFalseType = 4
    
}HAQuestionType;

@interface HAQuizDataManager : NSObject
{
    NSUInteger _currentQuizCategory;
    NSString* _currentQuizCategoryName;
    HAQuizDataFormatType _useSourceDataFormat;
     NSUInteger _currentNumberOfQuestionRequiredAfterSuffle;
    __strong NSMutableSet* _allPurchaseIdentifiers;
    __strong NSDictionary* _currentCategoryDict;

}
@property (nonatomic, strong) NSMutableSet* _allPurchaseIdentifiers;
@property (nonatomic, assign) HAQuizDataFormatType _useSourceDataFormat;
@property (nonatomic, assign) NSUInteger _currentQuizCategory;
@property (nonatomic, retain) NSString* _currentQuizCategoryName;
@property (nonatomic, strong) NSDictionary* _currentCategoryDict;
@property (nonatomic ,assign) NSUInteger _currentNumberOfQuestionRequiredAfterSuffle;
+(HAQuizDataManager*)sharedManager;

//Quiz Data Related methods
- (NSArray *)allQuizCategories;
- (NSArray *)quizCategories;
- (NSArray *)questionsForCategoty:(NSUInteger)inCategory;
- (NSString *)pathForJASONDataFormatWithCategory:(NSUInteger)inCategory;
- (NSString *)pathForPLISTDataFormatWithCategory:(NSUInteger)inCategory;
- (NSString *)pathForPictureName:(NSString *)inPictureFileName;
//high score relate methods
- (void)setHighScore:(int64_t)inHighScore forQuizCategoryType:(NSUInteger)inCategory;
- (NSUInteger)highScoreForQuizCategory:(NSUInteger)inCategory;
- (NSMutableArray *)highScores;
- (NSDictionary* )categoryDictForCategoryId:(NSUInteger)inCategoryID;
- (void)setInitialHighscores;
- (NSString *)categoryFolderPath;
//InApp purchase related
- (NSArray *)quizCategoriesRequirePurchase;
//Attempeted questions related methods
- (NSUInteger)attemptedQuestionsCountForCategory:(NSString *)categoryID;
- (void)markQuestionRead:(NSString *)question forCategoryID:(NSString *)categoryID;
- (NSUInteger)questionsCountForCategoryID:(NSString *)categoryID;
- (void)updateQuestionsCountForAllCategories;
- (NSArray *)allQuestionsForCategory:(NSString *)categoryID;
- (NSDictionary *)highScoreDictForQuizCategory:(NSString *)inCategory;

#pragma mark - Multiplayer related methods
- (NSData *)dataForMultiplayer:(NSDictionary *)categoryDict andQuestions:(NSArray *)questions pointsObtained:(int64_t)inPoints forPlayerID:(NSString *)inPlayerID;
- (NSDictionary *)dataDictionaryFromPreviousParticipantMatchData:(NSData *)inData;
- (NSData *)newDataForMatchData:(NSData *)inData withPoints:(int64_t)inPoints forPlayerID:(NSString *)inPlayerID;
@end