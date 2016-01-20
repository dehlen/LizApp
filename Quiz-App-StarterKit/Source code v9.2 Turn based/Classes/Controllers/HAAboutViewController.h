//
//  HAAboutViewController.h
//  TAKE A TEST
//
//  Created by Pavithra Satish on 12/05/14.
//  Copyright (c) 2014 Heaven Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAAboutViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIImageView* _bgImageView;
@property (nonatomic, weak) IBOutlet UITextView* _aboutTextView;
@property (nonatomic, weak) IBOutlet UIButton* _homeButton;
@property (nonatomic, weak) IBOutlet UILabel* _titleLabel;
@property (nonatomic, weak) IBOutlet UIWebView* _webView;

@end
