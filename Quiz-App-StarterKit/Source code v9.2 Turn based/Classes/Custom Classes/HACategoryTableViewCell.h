//
//  HACategoryTableViewCell.h
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 13/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HACategoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel* _titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* _highscoreLabel;
@property (weak, nonatomic) IBOutlet UILabel* _timeLimitLabel;
@property (weak, nonatomic) IBOutlet UILabel* _priceLabel;
@property (weak, nonatomic) IBOutlet UIButton* _buyButton;
@property (weak, nonatomic) IBOutlet UIImageView* _categoryImageView;
@property (weak, nonatomic) IBOutlet UIImageView* _categoryBGImageView;
@property (weak, nonatomic) IBOutlet UILabel* _descriptionLabel;
@property (weak, nonatomic) IBOutlet UIProgressView* _progressView;
@property (weak, nonatomic) IBOutlet UILabel* _percentageLabel;
@property (weak, nonatomic) IBOutlet UILabel* _highscoreDisplayLabel;
@property (nonatomic, assign) BOOL _animated;
@end
