//
//  HASettingsViewController.m
//  QUIZ_APP
//
//  Created by Pavithra Satish on 25/12/14.
//  Copyright (c) 2014 Heaven Apps. All rights reserved.
//

#import "HASettingsViewController.h"
#import "RageIAPHelper.h"

@interface HASettingsViewController ()

@end

@implementation HASettingsViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self._bgImageView.image = [UIImage imageNamed:[HAUtilities resourceNameForString:@"quizBg"]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self._titleLabel.font = [UIFont fontWithName:self._titleLabel.font.fontName size:30.0];
    }

    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self._doneButton];
    [self._settingsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self._doneButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    
    if ([HASettings sharedManager]._isInAppPurchaseSupported) {
        if ([HASettings sharedManager]._isAdSupported == NO || [HASettings sharedManager]._isAdsTurnedOff)
        {
            self._removeAdsButton.hidden = YES;
            self._restoreButton.hidden = YES;
        }
        else{
            [self._removeAdsButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
            [self._restoreButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
        }
    }
    else{
        self._removeAdsButton.hidden = YES;
        self._restoreButton.hidden = YES;
    }
    
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:IAPHelperProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    self.navigationItem.titleView = self._titleLabel;
    
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Action methods
- (IBAction)doneAction:(id)sender
{
    [HAUtilities playTapSound];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)restoreAction:(id)sender
{
    
}

- (void)removeAdsAction:(UIButton *)sender
{
    NSString* removeAdsProductIdentifier = [HASettings sharedManager]._removeAdsProdcutIdentifier;
    BOOL adsRemoved = [[NSUserDefaults standardUserDefaults] valueForKey:[HASettings sharedManager]._removeAdsProdcutIdentifier] == nil ? NO : YES;
    _removeAds = YES;
        if (adsRemoved)
        {
            [[HASettings sharedManager] setAdsTurnedOff:YES];
        }
        else
        {
            if (![RageIAPHelper sharedInstance]._products.count)
            {
                
                [[RageIAPHelper sharedInstance] loadProducts];
            }
            else
            {
                NSUInteger productIndex = 0;
                BOOL found = NO;
                for (SKProduct* product in [RageIAPHelper sharedInstance]._products) {
                    productIndex++;
                    if ([product.productIdentifier isEqualToString:removeAdsProductIdentifier]) {
                        found = YES;
                    }
                }
                
                if (found)
                {
                    sender.tag = productIndex;
                    [self buyAction:sender];
                    _removeAds = NO;
                }
            }
        }
}

- (void)soundsSwitch:(UISwitch *)sender
{
    [[HASettings sharedManager] setSoundsEnabled:sender.isOn];
}

- (void)showExplanation:(UISwitch *)sender
{
    [[HASettings sharedManager] setShowExplanation:sender.isOn];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = self._doneButton.titleLabel.font;
    cell.textLabel.textColor = [HASettings sharedManager]._appTextColor;


    if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Sounds";
            [self._soundsSwitch removeFromSuperview];
            self._soundsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.frame) - 51.0, CGRectGetMidX(cell.frame) - 15.5, 50.0, 31.0)];
            [self._soundsSwitch setOn:[HASettings sharedManager]._isSoundsOn];
            [self._soundsSwitch addTarget:self action:@selector(soundsSwitch:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self._soundsSwitch;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"Show explanations";
            [self._showExplanationSwitch removeFromSuperview];
            self._showExplanationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.frame) - 51.0, CGRectGetMidX(cell.frame) - 15.5, 50.0, 31.0)];
            [self._showExplanationSwitch setOn:[HASettings sharedManager]._showExplanation];
            [self._showExplanationSwitch addTarget:self action:@selector(showExplanation:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self._showExplanationSwitch;
        }
    
        [self._soundsSwitch setOn:[HASettings sharedManager]._isSoundsOn];
        self._showExplanationSwitch.onTintColor = [HASettings sharedManager]._appTextColor;
        self._soundsSwitch.onTintColor = [HASettings sharedManager]._appTextColor;
    
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:25.0];
    }

    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    NSString* productIdentifier = [HASettings sharedManager]._removeAdsProdcutIdentifier;
    
    for (SKProduct * product in [RageIAPHelper sharedInstance]._products) {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            [[RageIAPHelper sharedInstance] buyProduct:product];
        }
    }
}

- (void)productPurchased:(NSNotification *)notification {
    NSLog(@"notification : %@",[notification description]);
    
    if ([notification.object isEqualToString:[HASettings sharedManager]._removeAdsProdcutIdentifier])
    {
        [[HASettings sharedManager] setAdsTurnedOff:YES];
        self._removeAdsButton.hidden = YES;
        self._restoreButton.hidden = YES;
    }
}

- (void)productsLoaded:(NSNotification *)nc
{
    if (_removeAds) {
        [self removeAdsAction:self._removeAdsButton];
    }
}

- (void)restore {
    [[RageIAPHelper sharedInstance] restoreCompletedTransactions];
}

@end
