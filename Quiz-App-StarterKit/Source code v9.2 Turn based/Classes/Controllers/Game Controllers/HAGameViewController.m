//
//  HAGameViewController.m
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 31/07/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import "HAGameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "HAFinalScoreViewController.h"
#import "HATurnbasedFinalViewController.h"
#import "AppDelegate.h"


#define kColorTill25Percentage [UIColor colorWithRed:109.0/255.0 green:253/255.0 blue:4.0/255.0 alpha:1.0]
#define kColorTill25To50Percentage [UIColor colorWithRed:1.0 green:253/255.0 blue:56.0/255.0 alpha:1.0]
#define kColorTill50To75Percentage [UIColor colorWithRed:1.0 green:204.0/255.0 blue:0.0 alpha:1.0]
#define kColorTill75PercentageTo100 [UIColor colorWithRed:240.0/255.0 green:27.0/255.0 blue:62.0/255.0 alpha:1.0]


//Here fade animation duaration can be set, if slide animation is used this setting wont be used
#define kFadeOutAnimationDuration 0.3 
#define kHorizontalLeftSpace 20.0


@interface  MyMoviePlayer : AVPlayerViewController
@property (nonatomic, assign) BOOL _isVideoStopped;
@property (nonatomic, assign) BOOL _isVideoStarted;
@end

@implementation MyMoviePlayer

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationController.navigationBar.translucent = NO;

    AppDelegate *mainDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    mainDelegate._shouldRotate = YES;
//     self.moviePlayer.controlStyle = MPMovieControlStyleNone;
//    [self.moviePlayer setScalingMode:MPMovieScalingModeNone];
//    [self.moviePlayer setFullscreen:YES animated:YES];
    self.showsPlaybackControls = YES;

}

- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController
{
    self._isVideoStopped = YES;
    self._isVideoStarted = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoStopped" object:nil userInfo:nil];
    AppDelegate *mainDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    mainDelegate._shouldRotate = NO;
}


-(void) CloseMPMoviePlayerWhenNeeded{
    self._isVideoStopped = YES;
    self._isVideoStarted = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoStopped" object:nil userInfo:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


@end


@interface HAGameViewController (Private)
- (void)initialization; 
- (void)releaseAllViews;
- (void)showQuestionAtIndex:(int)inIndex; //Shows the question with options for the index passed
- (void)startQuiz; //This method starts the quiz game
- (void)animateUI; //Animates UI depending on _animationType choosen
- (void)hideOptions; //take all the options offscreen before slide animation is shown
- (void)highlightAnswers:(UIButton *)optionButton;
- (void)resetOptionsBackgroundImages;
- (NSArray *)shuffledOptionsForOptions:(NSArray *)inOptions;
- (void)start;
- (void)stop;
- (void)animateUIForTrueFalseQuestionType;
- (void)timeEndingAnimationWithInfiniteTimes:(BOOL)inInfinite;
- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
@end

@implementation HAGameViewController (Private)

- (void)releaseAllViews
{
    //release all your outlets and views allocated
}
- (void)initialization
{
    _animationType = eHAQuizGamaAnimationSlideAnimationForOptionsType;
    self._dataManager = [HAQuizDataManager sharedManager];
    _isPictureMadeAutoSmall = NO;
    questionIndex = 0;
    _currentScore = 0;
     //here you send the type of animation fadeInOur or slide animation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishPlaying:) name:@"VideoStopped" object:nil];
    [HASettings sharedManager]._isGameScreenVisible = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipQuestionWhenAppComesForeground:) name:@"skipCurrentQuestion" object:nil];
}

- (void)hideOptions
{
        _option0ContainerView.frame = CGRectMake(-_option0ContainerView.frame.size.width,_option0ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
        _option1ContainerView.frame = CGRectMake(-_option1ContainerView.frame.size.width,_option1ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
        _option2ContainerView.frame = CGRectMake(-_option2ContainerView.frame.size.width,_option2ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
        _option3ContainerView.frame = CGRectMake(-_option3ContainerView.frame.size.width,_option3ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
}

- (void)resetOptionsBackgroundImages
{

    if (_currentQuestionType == eHAQuestionTrueFalseType && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        NSString* optionBgImageName = @"optionBg_default";//[NSString stringWithFormat:@"optionBg_default%d",(i+1)];
        [_optionButtonFalse setBackgroundImage:[UIImage imageNamed:[HAUtilities resourceNameForString:optionBgImageName]] forState:UIControlStateNormal];
        [_optionButtonTrue setBackgroundImage:[UIImage imageNamed:[HAUtilities resourceNameForString:optionBgImageName]] forState:UIControlStateNormal];

    }
    else
    {
        int i;
        NSUInteger count = [_optionsButtonsArray count];
        for (i=0; i<count; i++)
        {
            UIButton* optionButton = [_optionsButtonsArray objectAtIndex:i];
            NSString* optionBgImageName = @"optionBg_default";//[NSString stringWithFormat:@"optionBg_default%d",(i+1)];
            [optionButton setBackgroundImage:[UIImage imageNamed:[HAUtilities resourceNameForString:optionBgImageName]] forState:UIControlStateNormal];
            [optionButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        }
    }
}

//This method sets blue,green and red methods depending on the option is correct or wrong (green and red effect can be seen when user taps on the ans)
- (void)highlightAnswers:(UIButton *)optionButton
{
    NSUInteger correctAns = [[currentQuestionDict objectForKey:kQuizAnswer] intValue];
    
    if (_currentQuestionType == eHAQuestionTrueFalseType)
    {
        if (optionButton.tag == correctAns) {
            NSString* optionBgGreenImageName = @"optionBg_green";
            [optionButton setBackgroundImage:[UIImage imageNamed:[HAUtilities resourceNameForString:optionBgGreenImageName]] forState:UIControlStateNormal];
        }
        else{
            NSString* optionBgRedImageName = @"optionBg_red";
            [optionButton setBackgroundImage:[UIImage imageNamed:[HAUtilities resourceNameForString:optionBgRedImageName]] forState:UIControlStateNormal];
        }
    }
    else
    {
        int i;
        NSUInteger count = [_optionsButtonsArray count];
            if (optionButton.tag != correctAns)
            {
                NSLog(@"wrong option : %ld",(long)optionButton.tag);
                NSString* optionBgRedImageName = @"optionBg_red";//[NSString stringWithFormat:@"optionBg_red%d",(optionClickedIndex+1)];
                [optionButton setBackgroundImage:[UIImage imageNamed:[HAUtilities resourceNameForString:optionBgRedImageName]] forState:UIControlStateNormal];
                
                BOOL showCorrectOptionWhenAnsweredWrong = [HASettings sharedManager]._isHighlightCorrectAnswerEnabled;
                
                if (showCorrectOptionWhenAnsweredWrong) {
                    for (i=0; i<count; i++)
                    {
                        UIButton* correctOptionButton = [_optionsButtonsArray objectAtIndex:i];
                        NSString* optionBgGreenImageName = @"optionBg_green";//[NSString stringWithFormat:@"optionBg_green%d",(i+1)];
                        
                        
                        if (correctOptionButton.tag == correctAns)
                        {
                            [correctOptionButton setBackgroundImage:[UIImage imageNamed:[HAUtilities resourceNameForString:optionBgGreenImageName]] forState:UIControlStateNormal];
                        }
                    }
                }

            }
        
        
        if(optionButton.tag == correctAns)
        {
            for (i=0; i<count; i++)
            {
                UIButton* correctOptionButton = [_optionsButtonsArray objectAtIndex:i];
                NSString* optionBgGreenImageName = @"optionBg_green";//[NSString stringWithFormat:@"optionBg_green%d",(i+1)];
                
                
                if (correctOptionButton.tag == correctAns)
                {
                    [correctOptionButton setBackgroundImage:[UIImage imageNamed:[HAUtilities resourceNameForString:optionBgGreenImageName]] forState:UIControlStateNormal];
                }
            }
        }
    }
}


- (void)animateUI
{    
    if (_animationType == eHAQuizGameAnimationFadeInFadeOutType) 
    {
        //fadeIn and FadeOut animation for the views, if any view require this effect you can add here
        [HAUtilities fadeInOutView:_option0ContainerView withDuration:kFadeOutAnimationDuration];
        [HAUtilities fadeInOutView:_option1ContainerView withDuration:kFadeOutAnimationDuration];
        [HAUtilities fadeInOutView:_option2ContainerView withDuration:kFadeOutAnimationDuration];
        [HAUtilities fadeInOutView:_option3ContainerView withDuration:kFadeOutAnimationDuration];
        [HAUtilities fadeInOutView:_currentQuestionTextView withDuration:kFadeOutAnimationDuration];        
        [HAUtilities fadeInOutView:_scoreLabel withDuration:kFadeOutAnimationDuration];
        [HAUtilities fadeInOutView:_currentQuestionLabel withDuration:kFadeOutAnimationDuration];
//        [HAUtilities fadeInOutView:_currentQuestionPointsLabel withDuration:kFadeOutAnimationDuration];
    }
    else if (_animationType == eHAQuizGamaAnimationSlideAnimationForOptionsType)
    {
        
        [self hideOptions];
        
        CGRect rect0;
        CGRect rect1;
        CGRect rect2;
        CGRect rect3;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            rect0 = CGRectMake(0.0,_option0ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
            rect1 = CGRectMake(0.0,_option1ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
            rect2 = CGRectMake(0.0,_option2ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
            rect3 = CGRectMake(0.0,_option3ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
            
        }
        else
        {
            rect0 = CGRectMake(0.0,_option0ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
            rect1 = CGRectMake(0.0,_option1ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
            rect2 = CGRectMake(0.0,_option2ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
            rect3 = CGRectMake(0.0,_option3ContainerView.frame.origin.y, _option0ContainerView.frame.size.width, _option0ContainerView.frame.size.height);
            
        }
        
        
        _option0ContainerView.userInteractionEnabled = NO;
        _option1ContainerView.userInteractionEnabled = NO;
        _option2ContainerView.userInteractionEnabled = NO;
        _option3ContainerView.userInteractionEnabled = NO;

        [UIView beginAnimations:@"optionAnimation" context:(__bridge void*)_option0ContainerView];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.4];
        _option0ContainerView.frame = rect0;
        [UIView commitAnimations];
        
        [UIView beginAnimations:@"optionAnimation" context:(__bridge void*)_option1ContainerView];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.6];
        _option1ContainerView.frame = rect1;
        [UIView commitAnimations];
        
        [UIView beginAnimations:@"optionAnimation" context:(__bridge void*)_option2ContainerView];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.8];
        _option2ContainerView.frame = rect2;
        [UIView commitAnimations];
        
        [UIView beginAnimations:@"optionAnimation" context:(__bridge void*)_option3ContainerView];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];

        _option3ContainerView.frame = rect3;
        [UIView commitAnimations];
    }    
}

- (void)animateUIForTrueFalseQuestionType
{
    if (_animationType == eHAQuizGameAnimationFadeInFadeOutType)
    {
        //fadeIn and FadeOut animation for the views, if any view require this effect you can add here
        [HAUtilities fadeInOutView:_optionButtonTrue withDuration:kFadeOutAnimationDuration];
        [HAUtilities fadeInOutView:_optionButtonFalse withDuration:kFadeOutAnimationDuration];
        [HAUtilities fadeInOutView:_currentQuestionTextView withDuration:kFadeOutAnimationDuration];
        [HAUtilities fadeInOutView:_scoreLabel withDuration:kFadeOutAnimationDuration];
        [HAUtilities fadeInOutView:_currentQuestionLabel withDuration:kFadeOutAnimationDuration];
//        [HAUtilities fadeInOutView:_currentQuestionPointsLabel withDuration:kFadeOutAnimationDuration];
        
    }
    else if (_animationType == eHAQuizGamaAnimationSlideAnimationForOptionsType)
    {
        
        //send true and false buttons out side the screen
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            _optionButtonTrue.frame = CGRectMake(-769.0,_optionButtonTrue.frame.origin.y, _optionButtonTrue.frame.size.width, _optionButtonTrue.frame.size.height);
            _optionButtonFalse.frame = CGRectMake(-876.0,_optionButtonFalse.frame.origin.y, _optionButtonTrue.frame.size.width, _optionButtonTrue.frame.size.height);
        }
        else
        {
            _optionButtonTrue.frame = CGRectMake(-322,_optionButtonTrue.frame.origin.y, _optionButtonTrue.frame.size.width, _optionButtonTrue.frame.size.height);
            _optionButtonFalse.frame = CGRectMake(-362,_optionButtonFalse.frame.origin.y, _optionButtonTrue.frame.size.width, _optionButtonTrue.frame.size.height);
        }
        
        CGRect rect0;
        CGRect rect1;
        
        //slide back frames for true false buttons
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            rect0 = CGRectMake(37.0,_optionButtonTrue.frame.origin.y, _optionButtonTrue.frame.size.width, _optionButtonTrue.frame.size.height);
            rect1 = CGRectMake(37.0,_optionButtonFalse.frame.origin.y, _optionButtonTrue.frame.size.width, _optionButtonTrue.frame.size.height);
            
        }
        else
        {
            rect0 = CGRectMake(9.0,_optionButtonTrue.frame.origin.y, _optionButtonTrue.frame.size.width, _optionButtonTrue.frame.size.height);
            rect1 = CGRectMake(9.0,_optionButtonFalse.frame.origin.y, _optionButtonTrue.frame.size.width, _optionButtonTrue.frame.size.height);
          
        }
        
        
        _optionButtonTrue.userInteractionEnabled = NO;
        _optionButtonFalse.userInteractionEnabled = NO;

        [UIView beginAnimations:@"optionAnimation" context:(__bridge void*)_optionButtonTrue];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.4];
        _optionButtonTrue.frame = rect0;
        [UIView commitAnimations];
        
        [UIView beginAnimations:@"optionAnimation" context:(__bridge void*)_optionButtonFalse];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.6];
        _optionButtonFalse.frame = rect1;
        [UIView commitAnimations];
        
    }    
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIView* view = (__bridge UIView*)context;
    if ([animationID isEqualToString:@"optionAnimation"]) {
        //enable option button userinteration once the animation is completed    
        view.userInteractionEnabled = YES;
    }
    else if ([animationID isEqualToString:@"pictureBecameSmall"])
    {
        _currentQuestionVideoPlayImageView.hidden = NO;
        _pictureContainerView.contentMode = UIViewContentModeScaleAspectFill;
        _currentQuestionPictureImageView.contentMode=UIViewContentModeScaleAspectFill;
        _pictureContainerView.userInteractionEnabled = YES;
        if (_isPictureMadeAutoSmall)
        {
            _isPictureMadeAutoSmall = NO;
            [self showQuestionAtIndex:questionIndex];
        }
    }
    else if ([animationID isEqualToString:@"pictureBecameLarge"])
    {
        _pictureContainerView.layer.cornerRadius = 0.0;
        _pictureContainerView.userInteractionEnabled = YES;
        _currentQuestionPictureImageView.contentMode = UIViewContentModeScaleAspectFit;
        timerLabel.hidden = NO;
        timerLabel.hidden = !_isTimerReQuired;
        [self.view insertSubview:timerLabel aboveSubview:_pictureContainerView];
    }
}

- (NSArray *)shuffledOptionsForOptions:(NSArray *)inOptions
{
    if ([HASettings sharedManager]._isShuffleAnswersEnabled)
    {
        NSUInteger count = [inOptions count];
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
        
        NSMutableArray* shuffledOptions = [[NSMutableArray alloc] initWithCapacity:4];
        for (int i=0; i<count; i++)
        {
            int randomIndex = [[shuffle objectAtIndex:i] intValue];
            [shuffledOptions addObject:[inOptions objectAtIndex:randomIndex]];
            UIButton* optionButton = [_optionsButtonsArray objectAtIndex:i];
            optionButton.tag = randomIndex;
        }
        return shuffledOptions;
        
    }
    
    return inOptions;
}

- (NSString *)uniqueIDforQuestion:(NSString *)inQuestion andOptions:(NSArray *)inOptions
{
    NSString* uniqueIdForQuestion;
    if (_currentQuestionType != eHAQuestionTrueFalseType) {
        NSString* str = [NSString stringWithFormat:@"%@%@%@%@%@",inQuestion,inOptions[0],inOptions[1],inOptions[2],inOptions[3]];
        uniqueIdForQuestion = [HAUtilities MD5StringForString:str];
        NSLog(@"uniqueIdForQuestion : %@ and question : %@",uniqueIdForQuestion,str);
    }
    else{
        NSString* str = [NSString stringWithFormat:@"%@",inQuestion];
        uniqueIdForQuestion = [HAUtilities MD5StringForString:str];
    }
    return uniqueIdForQuestion;
}

- (void)showQuestionAtIndex:(int)inIndex
{

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _optionButton0.enabled = YES;
    _optionButton1.enabled = YES;
    _optionButton2.enabled = YES;
    _optionButton3.enabled = YES;
    _optionButtonFalse.enabled = YES;
    _optionButtonTrue.enabled = YES;
    moviePlayer._isVideoStarted = NO;
    [self stop];
    [self runSpinAnimationOnView:self._progressView duration:1.0 rotations:0.2 repeat:500000];
    [self resetOptionsBackgroundImages];
    
    _stopCriticalAnimation = YES;
    if (questionIndex == [_questionsArray count])
    {
        if ([HASettings sharedManager]._isMultiplayerGame) {
            [self sendTurn];
        }
        else{
            HAFinalScoreViewController *controller = [[HAFinalScoreViewController alloc] initWithNibName:@"HAFinalScoreViewController" bundle:nil];
            controller._currentScore = _currentScore;
            [self.navigationController pushViewController:controller animated:YES];
            
            [_explanationTextView removeObserver:self forKeyPath:@"contentSize"];
            [_currentQuestionTextView removeObserver:self forKeyPath:@"contentSize"];
        }
        return;
    }
    else if (questionIndex > [_questionsArray count]) {
        return;
    }
    
    self.currentQuestionDict = [_questionsArray objectAtIndex:inIndex];
    NSString* question = [currentQuestionDict objectForKey:kQuizQuestion];
    //Setting options
    NSArray* options = [self shuffledOptionsForOptions:[currentQuestionDict objectForKey:kQuizOptions]];

    _currentQuestionType = [[currentQuestionDict objectForKey:kQuizQuestionType] intValue];
    
    [self._dataManager markQuestionRead:[self uniqueIDforQuestion:question andOptions:[currentQuestionDict objectForKey:kQuizOptions]] forCategoryID:[self._dataManager._currentCategoryDict objectForKey:kQuizCategoryId]];

    if (_currentQuestionType == eHAQuestionTrueFalseType)
    {
        [self setHideOptions:YES];
        [self animateUIForTrueFalseQuestionType];
    }
    else
    {
        [self setHideOptions:NO];
        [self animateUI];
    }

    
    if (_currentQuestionType == eHAQuestionTextType)
    {
        // set video play buttn hidden...
        
        [UIView animateWithDuration:0.5 animations:^{
            _pictureContainerView.alpha = 0.0;
        } completion:^(BOOL finished) {
            _pictureContainerView.hidden = YES;
            _currentQuestionPictureImageView.image = nil;
            _currentQuestionVideoPlayImageView.hidden=YES;
            _currentQuestionVideoPlayImageView.image=nil;
        }];

    }
    else if (_currentQuestionType == eHAQuestionPictureType)
    {
        // set video play buttn hidden...
        _currentQuestionVideoPlayImageView.hidden = NO;
        _currentQuestionVideoPlayImageView.image = [UIImage imageNamed:@"plus-icon.png"];
       
        //Set picture here
        NSString* pictureFileName = [currentQuestionDict objectForKey:kQuizQuestionPictureOrVideoName];
        NSString* picturePath = [self._dataManager pathForPictureName:pictureFileName];
        UIImage* currentPicture = [[UIImage alloc] initWithContentsOfFile:picturePath];
       // _currentQuestionPictureImageView.hidden = NO;
        _pictureContainerView.hidden = NO;
        _currentQuestionPictureImageView.contentMode=UIViewContentModeScaleAspectFill;
        _currentQuestionPictureImageView.image = currentPicture;
        
        [UIView animateWithDuration:0.5 animations:^{
            _pictureContainerView.alpha = 1.0;
        }];
    }
    else if (_currentQuestionType == eHAQuestionVideoType)
    {
        _currentQuestionVideoPlayImageView.hidden = NO;
         _currentQuestionVideoPlayImageView.image=[UIImage imageNamed:@"play-icon.png"];
        
        NSString* videoFileName = [currentQuestionDict objectForKey:kQuizQuestionPictureOrVideoName];
        NSString* videoPath = [self._dataManager pathForPictureName:videoFileName];
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *error = NULL;
        CMTime time = CMTimeMake(1, 65);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
        UIImage *FrameImage= [[UIImage alloc] initWithCGImage:refImg];
        _currentQuestionPictureImageView.hidden = NO;
        _currentQuestionPictureImageView.image = FrameImage;
        _pictureContainerView.hidden = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            _pictureContainerView.alpha = 1.0;
        }];

    }
    else if(_currentQuestionType == eHAQuestionTrueFalseType)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _pictureContainerView.alpha = 0.0;
        } completion:^(BOOL finished) {
            _pictureContainerView.hidden = YES;
            _currentQuestionPictureImageView.image = nil;
            _currentQuestionVideoPlayImageView.hidden=YES;
            _currentQuestionVideoPlayImageView.image=nil;
        }];
        
    }
    
    timerLabel.hidden = YES;
     _pictureContainerView.frame = _pictureOriginalRect;
    _pictureContainerView.clipsToBounds = YES;
    _pictureContainerView.layer.cornerRadius = _pictureContainerView.frame.size.width/2.0;
    
    _currentQuestionTextView.text = question;

    int i;
    NSUInteger count = [options count];
    for (i=0; i<count; i++)
    {
        UIButton* optionButton = [_optionsButtonsArray objectAtIndex:i];
        [optionButton setTitle:[options objectAtIndex:i] forState:UIControlStateNormal];

    }
    _currentQuestionLabel.text = [NSString stringWithFormat:@"%d/%lu",inIndex+1,(unsigned long)[_questionsArray count]];
//    NSString* points = [currentQuestionDict objectForKey:kQuizPoints];
//    _currentQuestionPointsLabel.text = [NSString stringWithFormat:@"+%@",points];
    currentTime = 0; //reset time
    [self start];
    
}

-(void)start
{
    if (_isTimerReQuired) {
        timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
        [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
    }
}
-(void)stop
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)timeEndingAnimationWithInfiniteTimes:(BOOL)inInfinite
{
    if (inInfinite)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self._progressView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                self._progressView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                if (_stopCriticalAnimation == NO && finished) {
                    [self timeEndingAnimationWithInfiniteTimes:YES];
                }
            }];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            self._progressView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                self._progressView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
            }];
        }];
    }
    
}



- (void)updateTimer:(NSTimer *)timer
{
    NSUInteger durationForQuestion = [[currentQuestionDict objectForKey:kQuizQuestionDutation] intValue];

    currentTime += 10.0 ;
    float seconds = currentTime/1000.0;
    
    self._progressView.progress = (float)seconds/(float)durationForQuestion;
    currentTimeOfQuestion = ceil(durationForQuestion - seconds);
    
    int currentPercentage = self._progressView.progress * 100;
    if (currentPercentage == 0) {
        self._progressView.tintColor = kColorTill25Percentage;
        [self timeEndingAnimationWithInfiniteTimes:NO];
    }
    else if (currentPercentage == 25)
    {
        self._progressView.tintColor = kColorTill25To50Percentage;
        [self timeEndingAnimationWithInfiniteTimes:NO];
    }
    else if (currentPercentage == 50){
        self._progressView.tintColor = kColorTill50To75Percentage;
        [self timeEndingAnimationWithInfiniteTimes:NO];
    }
    else if (currentPercentage ==75){
        self._progressView.tintColor = kColorTill75PercentageTo100;
        [self timeEndingAnimationWithInfiniteTimes:YES];
    }
    

    NSString* remainingTime = [NSString stringWithFormat:@"%lu",(unsigned long)currentTimeOfQuestion];
    _timeLeftLabel.text = remainingTime;
    timerLabel.text = remainingTime;
    
    if (_currentQuestionType == eHAQuestionVideoType && seconds == (durationForQuestion-2))
    {
        [moviePlayer CloseMPMoviePlayerWhenNeeded];
    }
    

    //after time for questions is elapsed move to next question
    if (seconds == durationForQuestion)
        
    {
        [self stop];        
        ++questionIndex;
        
        if (_pictureContainerView.frame.size.width == self.view.frame.size.width)
        {
            _isPictureMadeAutoSmall = YES;
            [self mediaTapped:nil];
        }
        else {
            [self showQuestionAtIndex:questionIndex];
        }
        
    }
    else {
        //_timerBar.currentValue = seconds;   
    }
}

- (void)startQuiz
{
    [self showQuestionAtIndex:0];
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


@end

@implementation HAGameViewController
@synthesize currentQuestionDict;
@synthesize _isTimerReQuired;
@synthesize _progressView;
@synthesize _themeColor;
@synthesize _questionsArray;

#pragma mark Initialization Methods 
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialization];
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[HAUtilities nibNameForString:nibNameOrNil] bundle:nibBundleOrNil];
    if (self) {
        [self initialization];
    }
    return self;
}

#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //hide timer if its disabled for this category node
    self._progressView.hidden = ![[self._dataManager._currentCategoryDict objectForKey:kTimerRequired] boolValue];
    [_explanationTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [_currentQuestionTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    self.view.clipsToBounds = YES;
    _timeLeftLabel.text = @"";
    _scoreLabel.text = @"";
    _currentQuestionLabel.text = @"";
    
    _currentQuestionTextView.textColor = [HASettings sharedManager]._appTextColor;
    
    _pictureOriginalRect = _pictureContainerView.frame;
    _pictureContainerView.clipsToBounds = YES;
    _pictureContainerView.layer.cornerRadius = _pictureContainerView.frame.size.width/2.0;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_skipButton];
    [_skipButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:self._homeButton];
    self.navigationItem.leftBarButtonItem = btn;
    
    UIColor* categoryColor = [HAUtilities colorFromHexString:[self._dataManager._currentCategoryDict objectForKey:kCategoryColor]];
    self._themeColor = categoryColor;
    self.navigationController.navigationBar.barTintColor = categoryColor;
    self.view.backgroundColor = categoryColor;
//    _timeLeftLabel.textColor = categoryColor;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediaTapped:)];
    [_pictureContainerView addGestureRecognizer:gesture];
    
    UITapGestureRecognizer* gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(explanationTapped:)];
    gesture1.numberOfTapsRequired = 1;
    [_explanationView addGestureRecognizer:gesture1];
    
    
    _scoreLabel.text = @"0"; //Chnage here for initial 0 points

    [self setHideOptions:YES];

    _categoryNameLabel.text = self._dataManager._currentQuizCategoryName;
    self.navigationItem.titleView = _categoryNameLabel;
    [self.view addSubview:_explanationView];
    _explanationView.hidden = YES;
    
    [self performSelector:@selector(startQuiz) withObject:nil afterDelay:0.3];
    
    [self._progressView setTintColor:[UIColor whiteColor]];
    self._progressView.trackColor = [UIColor blackColor];
    self._progressView.startAngle = (3.0*M_PI)/2.0;
    self._progressView.layer.contentsScale = [[UIScreen mainScreen] scale];
    

    
    self._innerProgressCircleView.layer.cornerRadius = self._innerProgressCircleView.frame.size.width / 2.0;
    self._innerProgressCircleView.backgroundColor = [categoryColor colorWithAlphaComponent:0.7];
    self._innerProgressCircleView.layer.contentsScale = [[UIScreen mainScreen] scale];
    
    self._innerProgressCircleView.layer.borderWidth = 3;
    self._innerProgressCircleView.layer.borderColor = [UIColor clearColor].CGColor;
    self._innerProgressCircleView.layer.shouldRasterize = YES;
    
    
    self._innerProgressCircleView.layer.shadowOffset = CGSizeMake(0, -1);
    self._innerProgressCircleView.layer.shadowOpacity = 1;
    self._innerProgressCircleView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    for (UIButton* optionButton in _optionsButtonsArray) {
        optionButton.exclusiveTouch = YES;
        [optionButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    }
    _timeLeftLabel.textColor = [HASettings sharedManager]._appTextColor;
    
    if (_isTimerReQuired == NO) {
        CGRect rect = _pointsContainerView.frame;
        rect.origin.x = [UIScreen mainScreen].bounds.size.width/2.0 - _pointsContainerView.frame.size.width/2.0;
        _pointsContainerView.frame = rect;
    }
    
    if ([HASettings sharedManager]._isMultiplayerGame) {
        self.navigationItem.hidesBackButton = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
        //restart timer animation
        if ([[[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kTimerRequired] boolValue]) {
            [self runSpinAnimationOnView:self._progressView duration:1.0 rotations:0.2 repeat:500000];
        }
    [self playBackgroundMusic];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (moviePlayer._isVideoStopped)
    {
        moviePlayer._isVideoStopped = NO;
        return;
    }

    [self setHideOptions:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (moviePlayer._isVideoStarted) {
        return;
    }
    
    [HASettings sharedManager]._isGameScreenVisible = NO;
    [self stop];
    [self._progressView.layer removeAllAnimations];
    
    
    //cheat catching
    if ([HASettings sharedManager]._isMultiplayerSupportEnabled && [HASettings sharedManager]._isMultiplayerGame && [HATurnbasedMatchHelper sharedInstance]._saveToLoseList)
    {
            if (questionIndex <= (_questionsArray.count-1)) {
                _currentScore = 0; //Make user lose this game fo killing the app intentionally
                [[HATurnbasedMatchHelper sharedInstance] saveCurrentMatchInLoseList];
                [HATurnbasedMatchHelper sharedInstance]._saveToLoseList = NO;
            }
    }
    [self stopBackgroundMusic];
}

- (void)viewDidUnload
{
    [self releaseAllViews];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation ==UIInterfaceOrientationPortraitUpsideDown);
}

-(void)dealloc
{
    [self stop];
    self._questionsArray = nil;
    _optionsButtonsArray = nil;
}

#pragma mark - Instance methods
- (void)startQuizForCategory:(int)inCategory
{
    if ([HASettings sharedManager]._isMultiplayerGame && _questionsArray.count) {
    }
    else{
        self._questionsArray = [self._dataManager questionsForCategoty:self._dataManager._currentQuizCategory];
    }
}

#pragma mark - Action Methods

- (IBAction)homeAction:(id)sender
{
    [_explanationTextView removeObserver:self forKeyPath:@"contentSize"];
    [_currentQuestionTextView removeObserver:self forKeyPath:@"contentSize"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)skipQuestionAction:(UIButton *)sender
{
    [HAUtilities playTapSound];
    ++questionIndex;
    [self showQuestionAtIndex:questionIndex];
}

- (IBAction)optionsTouchDown:(id)sender
{
    _optionButton0.enabled = YES;
    _optionButton1.enabled = YES;
    _optionButton2.enabled = YES;
    _optionButton3.enabled = YES;
    _optionButtonFalse.enabled = YES;
    _optionButtonTrue.enabled = YES;
}

- (IBAction)optionClicked:(UIButton *)sender
{
    
    if (sender == _optionButton0)
    {
        _optionButton1.enabled = false;
        _optionButton2.enabled = false;
        _optionButton3.enabled = false;
    }
    else if (sender == _optionButton1)
    {
        _optionButton0.enabled = false;
        _optionButton2.enabled = false;
        _optionButton3.enabled = false;
    }
    else if (sender == _optionButton2)
    {
        _optionButton1.enabled = false;
        _optionButton0.enabled = false;
        _optionButton3.enabled = false;
    }
    else{
        _optionButton1.enabled = false;
        _optionButton2.enabled = false;
        _optionButton0.enabled = false;
    }

    
    [self stop];
    _stopCriticalAnimation = YES;
    self.view.userInteractionEnabled = NO;
    NSUInteger index = [sender tag];
    BOOL soundOnOFF = [HASettings sharedManager]._isSoundsOn;

    [self highlightAnswers:sender];
    
    int correctAns = [[currentQuestionDict objectForKey:kQuizAnswer] intValue];
    NSString* explanationString = nil;
    if (correctAns == index)
    {
        if(soundOnOFF)
            [HAUtilities playSoundForCorrectAns:YES];

        BOOL  isTimeBasedScoreEnable = [HASettings sharedManager]._isTimerbasedScoreEnabled;
        BOOL isTimerRequired = [[self._dataManager._currentCategoryDict objectForKey:kTimerRequired] boolValue];
        
        NSUInteger answeredInSeconds = [[currentQuestionDict objectForKey:kQuizQuestionDutation] intValue] - currentTimeOfQuestion;

        if (isTimerRequired)
        {
        
            if (answeredInSeconds <= [HASettings sharedManager]._fullPointsBeforeSeconds) //give full points if user answers within seconds specified for key
            {
                _currentScore += [[currentQuestionDict objectForKey:kQuizPoints] integerValue];
            }
            else{
                if (isTimeBasedScoreEnable) {
                    float lapsedTime = [[currentQuestionDict objectForKey:kQuizQuestionDutation] intValue] - currentTimeOfQuestion;
                    _currentScore += ([[currentQuestionDict objectForKey:kQuizPoints] intValue] * (1.0 - ((float)lapsedTime/(float)[[currentQuestionDict objectForKey:kQuizQuestionDutation] intValue])));
                }
                else{
                    _currentScore += [[currentQuestionDict objectForKey:kQuizPoints] integerValue];
                }
            }
        }
        else{
            _currentScore += [[currentQuestionDict objectForKey:kQuizPoints] integerValue];
        }
        explanationString = [currentQuestionDict objectForKey:kCorrectAnsExplanation];
    }
    else //wrong ans
    {
        if(soundOnOFF)
            [HAUtilities playSoundForCorrectAns:NO];
        if ([HASettings sharedManager]._isMultiplayerGame) {
            //no negative points for multiplayer game
        }
        else{
            _currentScore -= [[currentQuestionDict objectForKey:kQuizNegativePoints] integerValue];
            explanationString = [currentQuestionDict objectForKey:kWrongAnsExplanation];
        }
    }
    _scoreLabel.text = [NSString stringWithFormat:@"%ld",(signed long)_currentScore]; //Change 'Points' text here
    
    if (explanationString.length == 0 || [HASettings sharedManager]._showExplanation == NO || [HASettings sharedManager]._isMultiplayerGame == YES)
    {
        [self performSelector:@selector(continueOptionClickedWithIndex:) withObject:[NSNumber numberWithInteger:index] afterDelay:1.5];
        NSLog(@"waiting ………………………");
    }
    else{
        [self continueOptionClickedWithIndex:[NSNumber numberWithInteger:index]];
        NSLog(@"not waiting ………………………");
    }
}

- (void)continueOptionClickedWithIndex:(NSNumber *)inIndexnumer
{
    int index = [inIndexnumer intValue];
    int correctAns = [[currentQuestionDict objectForKey:kQuizAnswer] intValue];
    NSString* explanationString = nil;
    NSString* correctInCorrectString = nil;
    //show explanation depending upon correct or wrong and play sound for the same.
    if (index == correctAns) {
        explanationString = [currentQuestionDict objectForKey:kCorrectAnsExplanation];
        correctInCorrectString = @"Correct";
    }
    else
    {
        explanationString = [currentQuestionDict objectForKey:kWrongAnsExplanation];
        correctInCorrectString = @"Incorrect";
    }
    _explanationTextView.text = explanationString;
    _correctWrongLabel.text = correctInCorrectString;
    [self showExplanation];
}

- (void)showExplanation
{
    if ([HASettings sharedManager]._showExplanation && [HASettings sharedManager]._isMultiplayerGame == NO)
    {
        if (_explanationTextView.text.length == 0) {
            ++questionIndex;
            [self showQuestionAtIndex:questionIndex];
            self.view.userInteractionEnabled = YES;
        }
        else
        {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            self.view.userInteractionEnabled = YES;
            _explanationView.hidden = NO;
            [self.view bringSubviewToFront:_explanationView];
        }
    }
    else{
        self.view.userInteractionEnabled = YES;
        ++questionIndex;
        [self showQuestionAtIndex:questionIndex];
    }
}

- (void)explanationTapped:(UITapGestureRecognizer *)gesture
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _explanationView.hidden = YES;
    ++questionIndex;
    [self showQuestionAtIndex:questionIndex];
    self.view.userInteractionEnabled = YES;
}

- (void)mediaTapped:(UITapGestureRecognizer *)inGesture
{
    CGRect rect;
    NSString* animationID;
    _pictureContainerView.userInteractionEnabled = NO;
    if (_currentQuestionType == eHAQuestionPictureType)
    {
        if (_pictureContainerView.frame.size.width == [UIScreen mainScreen].bounds.size.width) {
            rect = _pictureOriginalRect;
            animationID = @"pictureBecameSmall";
            timerLabel.hidden = YES;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            _pictureContainerView.layer.cornerRadius = _pictureOriginalRect.size.width/2.0;
        }
        else{

            _currentQuestionVideoPlayImageView.hidden = YES;
            _pictureContainerView.contentMode = UIViewContentModeScaleAspectFit;
             _currentQuestionPictureImageView.contentMode = UIViewContentModeScaleAspectFit;
            rect = [UIScreen mainScreen].bounds;
            animationID = @"pictureBecameLarge";
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
        
        [UIView beginAnimations:animationID context:nil];
        [UIView setAnimationDelay:0.2];
        [UIView setAnimationDuration:.4];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        _pictureContainerView.frame = rect;
        [UIView commitAnimations];
    }
    else if (_currentQuestionType == eHAQuestionVideoType)
    {
        if (currentTimeOfQuestion <= 2 && _isTimerReQuired)
        {
            return ;
        }

        
        _pictureContainerView.contentMode = UIViewContentModeScaleAspectFit;
        rect = self.view.frame;
        
        NSString* videoFileName = [currentQuestionDict objectForKey:kQuizQuestionPictureOrVideoName];
        NSString* videoPath = [self._dataManager pathForPictureName:videoFileName];
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        
        moviePlayer = [[MyMoviePlayer alloc] init];
        moviePlayer.player = [[AVPlayer alloc] initWithURL:url];
        moviePlayer._isVideoStarted = YES;
        moviePlayer.view.frame = self.view.frame;
        moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self presentViewController:moviePlayer animated:YES completion:NULL];
        moviePlayer.showsPlaybackControls = YES;
        moviePlayer.view.frame = rect;
        [moviePlayer.player play];

    }
}

- (void)nextQuestionAction:(id)sender
{
    if (_animationType == eHAQuizGameAnimationFadeInFadeOutType)
    {
        [self performSelector:@selector(continueNextQuestionAction) withObject:nil afterDelay:kFadeOutAnimationDuration];
    }
    else {
        [self continueNextQuestionAction];
    }
}
- (void)continueNextQuestionAction
{
    ++questionIndex;
    [self showQuestionAtIndex:questionIndex];
}

- (IBAction)trueFalseOptionClicked:(id)sender
{
    
    if (sender == _optionButtonFalse)
    {
        _optionButtonTrue.userInteractionEnabled = false;
    }
    else if (sender == _optionButtonTrue)
    {
        _optionButtonFalse.userInteractionEnabled = false;
    }

    
    [self stop];
    _stopCriticalAnimation = YES;
    self.view.userInteractionEnabled = NO;
    NSUInteger index = [sender tag];
    BOOL soundOnOFF = [HASettings sharedManager]._isSoundsOn;
    int correctAns = [[currentQuestionDict objectForKey:kQuizAnswer] intValue];
    if (correctAns == index) {
        if(soundOnOFF)
            [HAUtilities playSoundForCorrectAns:YES];

        BOOL  isTimeBasedScoreEnable = [HASettings sharedManager]._isSoundsOn;
        BOOL isTimerRequired = [[self._dataManager._currentCategoryDict objectForKey:kTimerRequired] boolValue];

        if (isTimerRequired) {
            
            if (isTimeBasedScoreEnable) {
                float lapsedTime = [[currentQuestionDict objectForKey:kQuizQuestionDutation] intValue] - currentTimeOfQuestion;
                _currentScore += ([[currentQuestionDict objectForKey:kQuizPoints] intValue] * (1.0 - ((float)lapsedTime/(float)[[currentQuestionDict objectForKey:kQuizQuestionDutation] intValue])));
            }
            else{
                _currentScore += [[currentQuestionDict objectForKey:kQuizPoints] integerValue];
            }
        }
        else{
            _currentScore += [[currentQuestionDict objectForKey:kQuizPoints] integerValue];
        }
    }
    else //wrong ans
    {
        if(soundOnOFF)
            [HAUtilities playSoundForCorrectAns:NO];
        
        if ([HASettings sharedManager]._isMultiplayerGame) {
            
        }
        else{
            _currentScore -= [[currentQuestionDict objectForKey:kQuizNegativePoints] integerValue];
        }
    }
    _scoreLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)_currentScore]; //Change 'Points' text here

    [self highlightAnswers:sender];
    [self performSelector:@selector(continueOptionClickedWithIndex:) withObject:[NSNumber numberWithInteger:index] afterDelay:1.5];
}

//Video stopped notification
- (void)videoDidFinishPlaying:(NSNotification *)nc
{
    AppDelegate *mainDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    mainDelegate._shouldRotate = NO;
    _pictureContainerView.userInteractionEnabled = YES;
    [moviePlayer.player pause];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self playBackgroundMusic];
}

- (void)setHideOptions:(BOOL)inValue
{

    if (_currentQuestionType == eHAQuestionTrueFalseType) {
            [_optionButtonTrue setHidden:NO];
            [_optionButtonFalse setHidden:NO];
            
            for (UIButton* optionButton in _optionsButtonsArray) {
                [optionButton setHidden:YES];
            }
    }
    else{
        for (UIButton* optionButton in _optionsButtonsArray) {
            [optionButton setHidden:inValue];
        }
        [_optionButtonTrue setHidden:YES];
        [_optionButtonFalse setHidden:YES];
    }
}


#pragma textview observers methods
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

#pragma mark - notification selectors
- (void)skipQuestionWhenAppComesForeground:(NSNotification *)nc
{
    _explanationView.hidden = YES;
    [self skipQuestionAction:nil];
}

#pragma mark - Turnbased methods
- (void)sendTurn
{
    AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    GKTurnBasedMatch *currentMatch = [HATurnbasedMatchHelper sharedInstance].currentMatch;

    
    if (currentMatch.matchData.length > 0) //this is second and final turn
    {
        [HATurnbasedMatchHelper sharedInstance]._saveToLoseList = NO; //user played so no need to mark him as lose.
        
            GKTurnBasedParticipant* player1 = currentMatch.currentParticipant;
            NSUInteger currentIndex = [currentMatch.participants
                                       indexOfObject:currentMatch.currentParticipant];
            GKTurnBasedParticipant* player2 = [currentMatch.participants objectAtIndex:
                                               ((currentIndex + 1) % [currentMatch.participants count])];
            
            NSData *data = [[HAQuizDataManager sharedManager] newDataForMatchData:currentMatch.matchData withPoints:_currentScore forPlayerID:currentMatch.currentParticipant.player.playerID];
            
            NSDictionary* quizDict = [[HAQuizDataManager sharedManager] dataDictionaryFromPreviousParticipantMatchData:currentMatch.matchData];
            NSInteger otherScore = [[quizDict objectForKey:[NSString stringWithFormat:@"%@_points",player2.player.playerID]] integerValue];

            if (_currentScore < otherScore)
            {
                player1.matchOutcome = GKTurnBasedMatchOutcomeLost;
                player2.matchOutcome = GKTurnBasedMatchOutcomeWon;
            }
            else if (_currentScore == otherScore)
            {
                player1.matchOutcome =  GKTurnBasedMatchOutcomeTied;
                player2.matchOutcome = GKTurnBasedMatchOutcomeTied;
            }
            else
            {
                [[HATurnbasedMatchHelper sharedInstance] iWon];
                player1.matchOutcome = GKTurnBasedMatchOutcomeWon;
                player2.matchOutcome = GKTurnBasedMatchOutcomeLost;
            }
        [appdelegate showActivityIndicator];
        [currentMatch endMatchInTurnWithMatchData:data completionHandler:^(NSError *error)
         {
             [HATurnbasedMatchHelper sharedInstance]._saveToLoseList = NO;
             if (error) //unable to end match
             {
                 [HATurnbasedMatchHelper sharedInstance]._currentMatchScore = _currentScore;
                 [[HATurnbasedMatchHelper sharedInstance] saveCurrentMatchInResubmissionList];
                 
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"An error occured while ending match. Your Match will be resubmitted automatically when network is back." preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                 [alertController addAction:ok];
                 [self presentViewController:alertController animated:YES completion:^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                 }];
             }
             else
             {
                 HATurnbasedFinalViewController* controller = [[HATurnbasedFinalViewController alloc] initWithNibName:@"HATurnbasedFinalViewController" bundle:nil];
                 controller._match = [HATurnbasedMatchHelper sharedInstance].currentMatch;
                 controller._isPushedFromGC = NO;
                 [self.navigationController pushViewController:controller animated:YES];
             }
             [appdelegate hideActivityIndicator];
         }];
    }
    else
    {
        NSUInteger currentIndex = [currentMatch.participants
                                   indexOfObject:currentMatch.currentParticipant];
        GKTurnBasedParticipant *nextParticipant;
        nextParticipant = [currentMatch.participants objectAtIndex:
                           ((currentIndex + 1) % [currentMatch.participants count ])];
        
        //matchdata, playerID and number of wins
        NSData *data = [[HAQuizDataManager sharedManager] dataForMultiplayer:[HAQuizDataManager sharedManager]._currentCategoryDict andQuestions:_questionsArray pointsObtained:_currentScore forPlayerID:currentMatch.currentParticipant.player.playerID];
        
        NSLog(@"data bytes : %lu",(unsigned long)data.length);
        NSLog(@"matchDataMaximumSize %lu",(unsigned long)currentMatch.matchDataMaximumSize);
        if (data.length <= currentMatch.matchDataMaximumSize)
        {
            [appdelegate showActivityIndicator];
            [currentMatch endTurnWithNextParticipants:[NSArray arrayWithObject:nextParticipant] turnTimeout:GKTurnTimeoutNone matchData:data completionHandler:^(NSError *error) {
                if (error) {
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"An error occured while submitting your turn, please play again" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    [appdelegate._navController presentViewController:alertController animated:YES completion:^{
                    }];
                    [self.navigationController popToRootViewControllerAnimated:YES];

                }
                else{
                    [[HATurnbasedMatchHelper sharedInstance] addMatchID:currentMatch.matchID];
                    HATurnbasedFinalViewController* controller = [[HATurnbasedFinalViewController alloc] initWithNibName:@"HATurnbasedFinalViewController" bundle:nil];
                    controller._match = currentMatch;
                    controller._isPushedFromGC = NO;
                    [self.navigationController pushViewController:controller animated:YES];
                }
                [appdelegate hideActivityIndicator];
            }];
            NSLog(@"Sending Turn…, %@, %@", data, nextParticipant);
        }
        else
        {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"Multiplayer trasact data bytes are more please set set \"category_questions_max_limit\" property value for category : %@ before uploading app to store",[HAQuizDataManager sharedManager]._currentQuizCategoryName] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [appdelegate._navController presentViewController:alertController animated:YES completion:^{
            }];
            [self.navigationController popViewControllerAnimated:YES];

        }
    }
    
    //report score for category played
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] initWithPlayers:@[[GKLocalPlayer localPlayer]]];
    leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
    leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
    leaderboardRequest.identifier = [[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kLeaderboardID];
    [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            GKScore *localPlayerScore = leaderboardRequest.localPlayerScore;
            _currentScore += localPlayerScore.value;
            GameCenterManager* gameCenterManager = [[GameCenterManager alloc] init];
            if (_currentScore != 0)
            {
                [gameCenterManager reportScore:[[NSNumber numberWithLongLong:_currentScore] longLongValue] forCategory:[[HAQuizDataManager sharedManager]._currentCategoryDict objectForKey:kLeaderboardID]];
                NSLog(@"multiplayer score reported");
            }
        }
    }];
}

- (void)quitGameOnFraudPlay
{
 /*   GKTurnBasedMatch* currentMatch = [HATurnbasedMatchHelper sharedInstance].currentMatch;
    NSUInteger currentIndex = [currentMatch.participants
                               indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    nextParticipant = [currentMatch.participants objectAtIndex:
                       ((currentIndex + 1) % [currentMatch.participants count ])];
    
    NSData *data = [[HAQuizDataManager sharedManager] dataForMultiplayer:[HAQuizDataManager sharedManager]._currentCategoryDict andQuestions:_questionsArray pointsObtained:_currentScore forPlayerID:currentMatch.currentParticipant.playerID];

    currentMatch.currentParticipant.matchOutcome = GKTurnBasedMatchOutcomeQuit;
    nextParticipant.matchOutcome = GKTurnBasedMatchOutcomeNone;
    [currentMatch endMatchInTurnWithMatchData:data completionHandler:^(NSError *error) {
        
    }];*/
}

#pragma mark - background music
- (void)playBackgroundMusic
{
    if ([HASettings sharedManager]._isSoundsOn) {
        NSURL *musicFile = [[NSBundle mainBundle] URLForResource:@"background_music"
                                                   withExtension:@"wav"];
        self._musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile
                                                                   error:nil];
        self._musicPlayer.numberOfLoops = -1;
        [self._musicPlayer play];
    }
}

- (void)stopBackgroundMusic
{
    if ([HASettings sharedManager]._isSoundsOn) {
        [self._musicPlayer stop];
        self._musicPlayer = nil;
    }
}

@end
