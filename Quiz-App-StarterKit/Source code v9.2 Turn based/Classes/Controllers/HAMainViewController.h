//
//  HAMainViewController.h
//  QUIZ_APP
//
//  Created by NIDHI on 29/06/13.
//
//

#import <UIKit/UIKit.h>
#import <RevMobAds/RevMobAds.h>
#import "HATurnbasedMatchHelper.h"
#import "HAQuizDataManager.h"

@interface HAMainViewController : UIViewController <GKGameCenterControllerDelegate, HATurnbasedMatchHelperDelegate>
{
    NSUInteger _ansForParentalQuestion;
    NSUInteger _productIndex;
    
}
@property (nonatomic, weak) IBOutlet UIView* _buttonsContainerView;
@property (nonatomic, weak) IBOutlet UIButton* _playButton;
@property (nonatomic, weak) IBOutlet UIButton* _aboutButton;
@property (nonatomic, weak) IBOutlet UIButton* _worldScoreButton;
@property (nonatomic, weak) IBOutlet UILabel* _titleView;
@property (nonatomic, weak) IBOutlet UIButton* _settingsButton;
@property (nonatomic, weak) IBOutlet UIButton* _getMoreCategoriesButton;
@property (nonatomic, weak) IBOutlet UIButton* _challengeButton;

@property (nonatomic, assign) BOOL _showGetMoreCategories;
@property (nonatomic, strong) RevMobBanner* _bannerAd;
@property (nonatomic, strong) HAQuizDataManager* _dataManager;

- (IBAction)playQuiz:(id)sender;
- (IBAction)aboutAction:(id)sender;
- (IBAction)worldScoreAction:(id)sender;
- (IBAction)settingsAction:(id)sender;
- (IBAction)getMoreCategories:(id)sender;
- (IBAction)multiplayerGameMode:(id)sender;
@end
