//
//  HAFinalScoreViewController.h
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 06/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterManager.h"
#import <GameKit/GameKit.h>


@interface HAFinalScoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GameCenterManagerDelegate,GKGameCenterControllerDelegate>
{
    IBOutlet UILabel* _scoreLabel;
    IBOutlet UILabel* _quizCategoryLabel;
    IBOutlet UILabel* _noHighScoresLabel;
    IBOutlet UIButton* _cancelButton;
    IBOutlet UITableView* _hiscoreTableView;
    
    NSMutableArray* _hiscoresArray;
    int64_t _currentScore;
    NSString* _quizCategoryName;
    IBOutlet UIButton* _worldScoreButton;
    GameCenterManager* gameCenterManager;
}
@property (nonatomic, strong) GameCenterManager* gameCenterManager;

@property (nonatomic, strong) NSMutableArray* _hiscoresArray;
@property (assign) int64_t _currentScore;
@property (nonatomic, strong) NSString* _quizCategoryName;
- (IBAction)facebookShareAction:(id)sender;
- (IBAction)twitterShareAction:(id)sender;
- (IBAction)homeAction:(id)sender;
- (IBAction)worldScoreAction:(id)sender;
@end
