//
//  HAQuizPurchaseCategoriesViewController.h
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 08/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAQuizPurchaseCategoriesViewController : UIViewController 
{
    
    
    NSArray* __strong _quizCategoriesArray;
    NSUInteger _ansForParentalQuestion;
    NSUInteger _productIndex;
    IBOutlet UILabel* _titleLabel;
    NSArray* _highScores;
}
@property (nonatomic, weak) IBOutlet UIButton* _homeButton;
@property (nonatomic, weak) IBOutlet UIButton* _restoreButton;
@property (nonatomic, strong) NSArray* _highScores;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView* _quizCategoriesTableView;
@property (strong, nonatomic) NSArray* _quizCategoriesArray;
- (IBAction)restoreTapped:(id)sender;
- (IBAction)homeAction:(id)sender;
- (void)buyProductAtIndex:(NSInteger)inIndex;
@end
