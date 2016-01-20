//
//  HAQuizCategoriesViewController.m
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 08/08/12.
//  Copyright (c) 2012 Heaven Apps. All rights reserved.
//

#import "HAQuizCategoriesViewController.h"
#import "HAGameViewController.h"
#import "SBJSON.h"
#import "HACategoryTableViewCell.h"
#import "UILabel+VerticalAlign.h"
#import "AppDelegate.h"
#import "RageIAPHelper.h"

@interface HAQuizCategoriesViewController (Private)
- (void)initialization;
- (void)releaseAllViews;
@end
@implementation HAQuizCategoriesViewController (Private)
- (void)initialization
{
    self._dataManager = [HAQuizDataManager sharedManager];
    self._quizCategoriesArray = nil;
}
- (void)releaseAllViews
{
    //release all your views and outlets here
    self._quizCategoriesTableView = nil;
}
@end

@implementation HAQuizCategoriesViewController
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
    _titleLabel.text = [HASettings sharedManager]._categoriesScreenTitle;
    self.navigationItem.titleView = _titleLabel;
    self._highScores = [self._dataManager highScores];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self._quizCategoriesTableView.hidden = NO;
    self._quizCategoriesArray = [self._dataManager quizCategories];
    [self._quizCategoriesTableView beginUpdates];
    [self._quizCategoriesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self._quizCategoriesTableView endUpdates];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self._quizCategoriesTableView visibleCells] == nil) {
        self._quizCategoriesTableView.hidden = YES;
    }
    
    if ([[HASettings sharedManager] requiredAdDisplay]) {
        [self loadAds];
        if (self._fullScreenAds) {
            [self._fullScreenAds showAd];
        }
        self._bannerAd = [[RevMobAds session] banner];
        [self._bannerAd loadWithSuccessHandler:^(RevMobBanner *banner) {
            [self._bannerAd showAd];
        } andLoadFailHandler:^(RevMobBanner *banner, NSError *error) {
            
        } onClickHandler:^(RevMobBanner *banner) {
        }];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([[HASettings sharedManager] requiredAdDisplay]) {
        self._fullScreenAds.delegate = nil;
        [self._bannerAd hideAd];
    }
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

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
    NSUInteger questionsCounts = [self._dataManager questionsCountForCategoryID:[categoryDict objectForKey:kQuizCategoryId]];
    NSUInteger attemptedQuestionCount = [self._dataManager attemptedQuestionsCountForCategory:[categoryDict objectForKey:kQuizCategoryId]];
    NSUInteger attemptedPercentage = ceil((CGFloat)attemptedQuestionCount/(CGFloat)questionsCounts * 100.0) > 100.0 ? 100.0 : ((CGFloat)attemptedQuestionCount/(CGFloat)questionsCounts * 100.0);
    cell._progressView.progress = (CGFloat)attemptedPercentage/100.0;
    NSString* percentageString = @"%";
    cell._percentageLabel.text = [NSString stringWithFormat:@"%lu%@",(unsigned long)attemptedPercentage,percentageString];

    
    NSUInteger hiscore = [self._dataManager highScoreForQuizCategory:[[categoryDict objectForKey:kQuizCategoryId] intValue]];
    cell._highscoreLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)hiscore];
    
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

    NSString* imagePath = [NSString stringWithFormat:@"%@/%@",[self._dataManager categoryFolderPath],[categoryDict objectForKey:kQuizCategoryImagePath]];//[[self._dataManager categoryFolderPath] stringByAppendingString:[categoryDict objectForKey:kQuizCategoryImagePath]];
    if (imagePath != nil && (NSNull *)imagePath != [NSNull null]) {
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(HACategoryTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* categoryDict = [_quizCategoriesArray objectAtIndex:indexPath.row];
    NSUInteger questionsCounts = [self._dataManager questionsCountForCategoryID:[categoryDict objectForKey:kQuizCategoryId]];
    NSUInteger attemptedQuestionCount = [self._dataManager attemptedQuestionsCountForCategory:[categoryDict objectForKey:kQuizCategoryId]];
    NSUInteger attemptedPercentage = ceil((CGFloat)attemptedQuestionCount/(CGFloat)questionsCounts * 100.0) > 100.0 ? 100.0 : ((CGFloat)attemptedQuestionCount/(CGFloat)questionsCounts * 100.0);
    [cell._progressView setProgress:0.0];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:2.0];
    [UIView setAnimationDuration:0.8];
    [cell._progressView setProgress:(CGFloat)attemptedPercentage/100.0 animated:YES];
    [UIView commitAnimations];
    NSString* percentageString = @"%";
    cell._percentageLabel.text = [NSString stringWithFormat:@"%lu%@",(unsigned long)attemptedPercentage,percentageString];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [HAUtilities playTapSound];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self playQuizAtIndex:indexPath.row];
}

- (void)playQuizAtIndex:(NSInteger)inIndex
{
    AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate._shouldRotate = NO;
    NSDictionary* currentCategoryDict = [_quizCategoriesArray objectAtIndex:inIndex];
    self._dataManager._currentCategoryDict = currentCategoryDict;
    
    self.title = @"";
    NSDecimalNumber* quizId  = [currentCategoryDict objectForKey:kQuizCategoryId];
    NSString* categoryName = [currentCategoryDict objectForKey:kQuizCategoryName];
    int quizIdInt = [quizId intValue];
    
    int currentNumberOfQuestionRequiredAfterSuffle = [[currentCategoryDict objectForKey:kCategoryQuestionLimit] intValue];
    
    if (currentNumberOfQuestionRequiredAfterSuffle == 0)
    {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"category_questions_max_limit is set to zero or key is missing for the category %@ and also make sure this count should not be more than number of questions in the Quetions_Category_%@",categoryName,quizId] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    NSString* xibName = nil;
    if ([UIScreen mainScreen].bounds.size.height == 568.0) {
        xibName = @"HAGameViewController-568";
    }
    else{
        xibName = @"HAGameViewController";
    }
    
    self._dataManager._currentQuizCategory = quizIdInt;
    self._dataManager._currentQuizCategoryName = categoryName;
    self._dataManager._currentNumberOfQuestionRequiredAfterSuffle = currentNumberOfQuestionRequiredAfterSuffle;
    
    HAGameViewController* controller = [[HAGameViewController alloc] initWithNibName:xibName bundle:nil];
    controller._isTimerReQuired = [[currentCategoryDict objectForKey:kTimerRequired] boolValue];
    [controller startQuizForCategory:quizIdInt];
    [self.navigationController pushViewController:controller animated:YES];
    
}
#pragma mark - Revmob delegates

- (void)loadAds {
    self._fullScreenAds = [[RevMobAds session] fullscreen];
    [self._fullScreenAds loadAd];
}


@end
