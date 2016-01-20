//
//  HASettingsViewController.h
//  QUIZ_APP
//
//  Created by Pavithra Satish on 25/12/14.
//  Copyright (c) 2014 Heaven Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HASettingsViewController : UIViewController 
{
    NSUInteger _ansForParentalQuestion;
    NSUInteger _productIndex;
    BOOL _removeAds;
}
@property (nonatomic, weak) IBOutlet UIImageView* _bgImageView;
@property (nonatomic, weak) IBOutlet UITableView* _settingsTableView;
@property (nonatomic, weak) IBOutlet UIButton* _doneButton;
@property (nonatomic, weak) IBOutlet UIButton* _removeAdsButton;
@property (nonatomic, weak) IBOutlet UIButton* _restoreButton;
@property (nonatomic, weak) IBOutlet UILabel* _titleLabel;
@property (nonatomic, strong) UISwitch* _soundsSwitch;
@property (nonatomic, strong) UISwitch* _showExplanationSwitch;
- (IBAction)doneAction:(id)sender;
- (IBAction)removeAdsAction:(id)sender;
- (IBAction)restoreAction:(id)sender;
- (void)restore;
@end
