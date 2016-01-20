//
//  HAQuizPurchaseCategoriesViewController.m
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 08/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import "HAQuizPurchaseCategoriesViewController.h"
#import "HAGameViewController.h"
#import "SBJSON.h"
#import "HAQuizDataManager.h"
#import "HACategoryTableViewCell.h"
#import "UILabel+VerticalAlign.h"
#import "AppDelegate.h"
#import "RageIAPHelper.h"


@interface HAQuizPurchaseCategoriesViewController (Private)
- (void)initialization;
- (void)releaseAllViews;
@end
@implementation HAQuizPurchaseCategoriesViewController (Private)
- (void)initialization
{
    //self._quizCategoriesArray = [[HAQuizDataManager sharedManager] quizCategoriesRequirePurchase];

}
- (void)releaseAllViews
{
    //release all your views and outlets here
    self._quizCategoriesTableView = nil;
}
@end

@implementation HAQuizPurchaseCategoriesViewController
@synthesize _quizCategoriesTableView;
@synthesize _quizCategoriesArray;
@synthesize _highScores;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[HAUtilities nibNameForString:nibNameOrNil] bundle:nibBundleOrNil];
    if (self) {
        [self initialization];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

-(void)dealloc
{
    [self releaseAllViews];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self._restoreButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self._homeButton];
    
    [self._homeButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    [self._restoreButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    
    _titleLabel.text = @"Get more categories";
    self.navigationItem.titleView = _titleLabel;
    self._highScores = [[HAQuizDataManager sharedManager] highScores];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];


}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self releaseAllViews];
}


#pragma mark - Action methods

- (IBAction)homeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.dragging || tableView.decelerating) {
        return;
    }
    
    CGRect myRect = [tableView rectForRowAtIndexPath:indexPath];
    
    //instead of 568, choose the origin of your animation
    cell.frame = CGRectMake(cell.frame.origin.x,
                            cell.frame.origin.y + [UIScreen mainScreen].bounds.size.height,
                            cell.frame.size.width,
                            cell.frame.size.height);
    
    [UIView animateWithDuration:0.4 delay:0.2 * indexPath.row options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //instead of -30, choose how much you want the cell to get "under" the cell above
        cell.frame = CGRectMake(myRect.origin.x,
                                myRect.origin.y - 30,
                                myRect.size.width,
                                myRect.size.height);
        
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 animations:^{
            cell.frame = myRect;
        }];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_quizCategoriesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    HACategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:[HAUtilities nibNameForString:@"HACategoryTableViewCell"] owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    
    NSDictionary* categoryDict = [_quizCategoriesArray objectAtIndex:indexPath.row];
    cell._categoryBGImageView.backgroundColor = [HAUtilities colorFromHexString:[categoryDict objectForKey:kCategoryColor]];
    //executed only if InApp Purchase is enabled
    NSString* productIdentifier = [categoryDict objectForKey:kProductIdentifier];
    cell._buyButton.hidden = NO;
    cell._priceLabel.hidden = NO;
    cell._highscoreLabel.hidden = YES;
    cell._percentageLabel.hidden = YES;
    cell._progressView.progress = 0.0;
    cell._highscoreDisplayLabel.hidden = YES;

    [cell._buyButton addTarget:self action:@selector(buyAction:) forControlEvents:UIControlEventTouchUpInside];
    cell._buyButton.tag = indexPath.row;
    

    cell._priceLabel.text = [[RageIAPHelper sharedInstance] productPriceForProductIdentifier:productIdentifier];
    
    UIColor* titleColor = cell._titleLabel.textColor;
    CGColorRef colorRef = [titleColor CGColor];
    size_t _countComponents = CGColorGetNumberOfComponents(colorRef);
    
    if (_countComponents == 4) {
        const CGFloat *_components = CGColorGetComponents(colorRef);
        CGFloat red     = _components[0];
        CGFloat green = _components[1];
        CGFloat blue   = _components[2];
//        CGFloat alpha = _components[3];
        cell._descriptionLabel.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.9];
    }
    cell._titleLabel.text = [categoryDict objectForKey:kQuizCategoryName];
    cell._descriptionLabel.text = [categoryDict objectForKey:kQuizCategoryDescription];
    [cell._descriptionLabel sizeThatFits:cell._descriptionLabel.frame.size];

    NSString* imagePath = [NSString stringWithFormat:@"%@/%@",[[HAQuizDataManager sharedManager] categoryFolderPath],[categoryDict objectForKey:kQuizCategoryImagePath]];    if (imagePath != nil && (NSNull *)imagePath != [NSNull null]) {
        imagePath = [imagePath stringByExpandingTildeInPath];
        cell._categoryImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    }
    else{
        cell._categoryImageView.image = nil;
    }
    [cell._titleLabel alignTop];
    
    BOOL timerRequired = [[categoryDict objectForKey:kTimerRequired] boolValue];
    if (timerRequired) {
        cell._timeLimitLabel.text = @"Timer based";
    }
    else{
        cell._timeLimitLabel.text = @"";
    }
    return cell;
}



#pragma mark - InApp Purchase related methods
- (void)buyAction:(id)sender
{
    if ([HASettings sharedManager]._isParentalGateEnabled)
    {
        _productIndex = [sender tag];
        NSArray* numbers = [NSArray arrayWithObjects:@"16",@"21",@"14",@"12",@"19",@"40",@"71",@"99",@"56",@"65",@"13",@"26",@"45", nil];
        int i = arc4random()%numbers.count;
        NSUInteger number = [[numbers objectAtIndex:i] intValue];
        _ansForParentalQuestion = number*2;
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Parental Gate"
                                                                       message:[NSString stringWithFormat:@"What is %lu X 2 = ?",(unsigned long)number]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //Do nothing
                                                         }];
        
        UIAlertAction* checkAction = [UIAlertAction actionWithTitle:@"Check" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          UITextField* textField = alert.textFields.firstObject;
                                          
                                          if (_ansForParentalQuestion == [[textField text] integerValue]) {
                                              [self buyProductAtIndex:_productIndex];
                                          }
                                      }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
            
        }];
        
        [alert addAction:okAction];
        [alert addAction:checkAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else{
        [self buyProductAtIndex:[sender tag]];
    }
}


- (void)buyProductAtIndex:(NSInteger)inIndex
{
    NSString* productIdentifier = [[_quizCategoriesArray objectAtIndex:inIndex] objectForKey:kProductIdentifier];
    
    for (SKProduct * product in [RageIAPHelper sharedInstance]._products) {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            [[RageIAPHelper sharedInstance] buyProduct:product];
        }
    }
}

- (void)productPurchased:(NSNotification *)notification {
    NSLog(@"notification : %@",[notification description]);
    
    
    self._quizCategoriesArray = [[HAQuizDataManager sharedManager] quizCategoriesRequirePurchase];
    if (self._quizCategoriesArray.count == 0)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self dismissViewControllerAnimated:YES completion:^{            
        }];
    }

    [_quizCategoriesTableView reloadData];
}

//- (void)productsLoaded:(NSNotification *)nc
//{
//    [self updateUIControls];
//    [_quizCategoriesTableView reloadData];
//}

- (IBAction)restoreTapped:(id)sender {
    [[RageIAPHelper sharedInstance] restoreCompletedTransactions];
}
@end
