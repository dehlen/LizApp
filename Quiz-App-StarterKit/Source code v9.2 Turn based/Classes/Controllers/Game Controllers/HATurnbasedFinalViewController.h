//
//  HATurnbasedFinalViewController.h
//  QUIZ_APP
//
//  Created by Pavithra Satish on 26/02/15.
//  Copyright (c) 2015 Heaven Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface HATurnbasedFinalViewController : UIViewController
{
    IBOutlet UIButton* _homeButton;
    IBOutlet UILabel* _currentPlayerStatusLabel;
    IBOutlet UILabel* _opponetPlayerStatusLabel;
    IBOutlet UILabel* _matchOutcomeLabel;
    IBOutlet UILabel* _matchStatusLabel;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UIButton* _rematchButton;
    IBOutlet UIButton* _withAnotherButton;
    
    IBOutlet UIButton* _fbButton;
    IBOutlet UIButton* _twitterButton;
}
@property (nonatomic, assign) BOOL _isPushedFromGC;
@property (nonatomic, assign) NSInteger _currentPlayerScore;
@property (nonatomic, assign) GKTurnBasedMatch* _match;
- (IBAction)homeAction:(id)sender;
- (IBAction)rematchAction:(id)sender;
- (IBAction)withAnotherAction:(id)sender;
- (IBAction)facebookShareAction:(id)sender;
- (IBAction)twitterShareAction:(id)sender;
@end
