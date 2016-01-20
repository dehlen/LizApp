//
//  HAGameViewController.h
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 31/07/12.
//  Copyright (c) 2012 Heven Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "HAUtilities.h"
#import "HAQuizDataManager.h"
#import "CERoundProgressView.h"
#import "CEPlayer.h"
#import "HATurnbasedMatchHelper.h"


@class MyMoviePlayer;

//Animation types supported for the game
enum HAQuizGameAnimationType
{
    eHAQuizGameAnimationFadeInFadeOutType = 1,
    eHAQuizGamaAnimationSlideAnimationForOptionsType,
};

typedef NSUInteger HAQuizGameAnimationType;


@interface HAGameViewController : UIViewController
{
    //4 answers buttons
    IBOutlet UIButton* _optionButton0;
    IBOutlet UIButton* _optionButton1;
    IBOutlet UIButton* _optionButton2;
    IBOutlet UIButton* _optionButton3;

    //4 answers button containerviews
    IBOutlet UIView* _option0ContainerView;
    IBOutlet UIView* _option1ContainerView;
    IBOutlet UIView* _option2ContainerView;
    IBOutlet UIView* _option3ContainerView;

    //true/false answers buttons
    IBOutlet UIButton* _optionButtonTrue;
    IBOutlet UIButton* _optionButtonFalse;
    
    IBOutlet UIButton* _skipButton;

    //category title & time remaining label
    IBOutlet UILabel* _categoryNameLabel;
    IBOutlet UILabel* _timeLeftLabel;
    
    //correct and wrong explaination popup views
    IBOutlet UITextView* _explanationTextView;
    IBOutlet UIView* _explanationView;
    IBOutlet UILabel* _correctWrongLabel;

    //picture or video thumbnail views
    IBOutlet UIView* _pictureContainerView;
    IBOutlet UIImageView* _currentQuestionPictureImageView;
    IBOutlet UIImageView* _currentQuestionVideoPlayImageView;

    //score, question, points, timer labels
    IBOutlet UILabel* _scoreLabel;
    IBOutlet UILabel* _currentQuestionLabel;
    IBOutlet UILabel* _currentQuestionPointsLabel;
    IBOutlet UITextView* _currentQuestionTextView;
    IBOutlet UILabel* timerLabel; //shown on fullscreen of image
    
    IBOutlet UIView* _pointsContainerView;
    
    int64_t _currentScore;
    NSDictionary* __strong currentQuestionDict;
    HAQuestionType _currentQuestionType;
    NSArray* _questionsArray;
    HAQuizGameAnimationType _animationType;

    //movie player for playing video of question
    MyMoviePlayer *moviePlayer;
    
    //contains outlets of 4 answers buttons
    IBOutletCollection(UIButton) NSArray* _optionsButtonsArray;
    UIColor* _themeColor;
    
    //others
    int questionIndex;
    NSTimer* _timeOutTimer;
    NSTimer * timer;
    float currentTime;
    CGRect _pictureOriginalRect;
    BOOL _isPictureMadeAutoSmall;
    NSUInteger currentTimeOfQuestion;
    BOOL _isTimerReQuired; //set from categories screen
    BOOL _stopCriticalAnimation;
}
@property (nonatomic, strong) UIColor* _themeColor;
@property (nonatomic, strong) IBOutlet CERoundProgressView *_progressView;
@property (nonatomic, strong) IBOutlet UIView* _innerProgressCircleView;
@property (nonatomic, strong) IBOutlet UIImageView* _bottomBackgrounImageView;
@property (nonatomic, strong) IBOutlet UIButton* _homeButton;
@property (nonatomic,assign) BOOL _isTimerReQuired;
@property (nonatomic, strong) NSArray* _questionsArray;
@property (strong, nonatomic) NSDictionary* currentQuestionDict; //This dictionary holds the current question details like question, options, ans etc
@property (nonatomic, strong) HAQuizDataManager* _dataManager;
@property (nonatomic, strong) AVAudioPlayer* _musicPlayer;

- (IBAction)optionClicked:(id)sender; 
- (IBAction)nextQuestionAction:(id)sender; //Takes you to the next question if its a last when then it will take you to final score screen
- (void)startQuizForCategory:(int)inCategory; //Starts quiz for given category_id ex: General Knowledge, History ect.
- (IBAction)trueFalseOptionClicked:(id)sender;
- (IBAction)skipQuestionAction:(UIButton *)sender;
- (void)setHideOptions:(BOOL)inValue;
- (void)videoDidFinishPlaying:(NSNotification *)nc;
- (void)mediaTapped:(UITapGestureRecognizer *)inGesture; //This methods is called when user taps on the picture.
- (void)explanationTapped:(UITapGestureRecognizer *)gesture;
- (void)skipQuestionWhenAppComesForeground:(NSNotification *)nc;
- (IBAction)optionsTouchDown:(id)sender;
- (void)sendTurn;
@end
