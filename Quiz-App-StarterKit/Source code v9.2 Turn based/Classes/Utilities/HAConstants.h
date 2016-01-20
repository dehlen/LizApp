//
//  HAConstants.h
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 06/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import <Foundation/Foundation.h>



//Add your chartboost appID and signature here
#define kChartboostAppID @"4f21c409cd1cb2fb7000001b"
#define kChartboostAppSignature @"92e2de2fd7070327bdeb54c15a5295309c6fcd2d"

//Add your Revmob appID here
#define kRevmobAppID @"51a1dd4737eb23bfe500006f"



typedef enum HAQuizDataFormatType
{
    eHAQuizDataFormatJsonType = 1,
    eHAQuizDataFormatPlistType
    
}HAQuizDataFormatType;

extern NSString* const kHighScore;
extern NSString* const kScore;
extern NSString* const kCurrentQuestionNumber;
extern NSString* const kQuizCategory;
extern NSString* const kQuizCategoryDescription;
extern NSString* const kQuizCategoryImagePath;
extern NSString* const kProductIdentifier;
extern NSString* const kTimerRequired;
extern NSString* const kLeaderboardID;
extern NSString* const kCategoryColor;

extern NSString* const kQuizCategoryId;
extern NSString* const kQuizCategoryName;
extern NSString* const kQuizCategories;
extern NSString* const kQuizQuestion;
extern NSString* const kQuizOptions;
extern NSString* const kQuizAnswer;
extern NSString* const kQuizPoints;
extern NSString* const kQuizNegativePoints;
extern NSString* const kQuizQuestionDutation;
extern NSString* const kQuizQuestionPictureOrVideoName;
extern NSString* const kQuizQuestionType;
extern NSString* const kQuizQuestionVideoName;
extern NSString* const kCategoryQuestionLimit;
extern NSString* const kCorrectAnsExplanation;
extern NSString* const kWrongAnsExplanation;
