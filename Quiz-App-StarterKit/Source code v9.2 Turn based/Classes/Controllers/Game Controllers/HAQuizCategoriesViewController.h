//
//  HAQuizCategoriesViewController.h
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 08/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAQuizDataManager.h"
#import "HATurnbasedMatchHelper.h"
#import <RevMobAds/RevMobAds.h>

@interface HAQuizCategoriesViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    NSArray* __strong _quizCategoriesArray;
    IBOutlet UILabel* _titleLabel;
    IBOutlet UILabel* _multiplayerModeLabel;
    NSArray* _highScores;
    BOOL _animateNow;
    NSInteger _selectedIndex;
}
@property (nonatomic, strong) NSMutableArray* _initialCellRectsForAnimation;
@property (nonatomic, strong) NSArray* _highScores;
@property (unsafe_unretained, nonatomic) UITableView* _quizCategoriesTableView;
@property (strong, nonatomic) NSArray* _quizCategoriesArray;
@property (strong, nonatomic) HAQuizDataManager* _dataManager;
@property (strong, nonatomic) RevMobFullscreen* _fullScreenAds;
@property (strong, nonatomic) RevMobBanner* _bannerAd;

- (IBAction)homeAction:(id)sender;
@end
