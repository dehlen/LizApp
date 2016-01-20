//
//  RageIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "RageIAPHelper.h"
#import "HAQuizDataManager.h"
#import "AppDelegate.h"
@implementation RageIAPHelper
@synthesize _productIdentifiers;

static RageIAPHelper* sharedInstance = nil;

//+ (RageIAPHelper *)sharedInstance {
//    static dispatch_once_t once;
//    static RageIAPHelper * sharedInstance;
//    dispatch_once(&once, ^{
//        sharedInstance = [[self alloc] init];
//    });
//    return sharedInstance;
//}

+ (RageIAPHelper *)sharedInstance
{
    @synchronized([HASettings class])
    {
        if (!sharedInstance)
            sharedInstance = [[self alloc] init];
        
        return sharedInstance;
    }
    return nil;
}

+(id)alloc
{
    @synchronized([HASettings class])
    {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}


- (NSSet *)identifiers
{
    if (self._productIdentifiers.count) {
        return self._productIdentifiers;
    }

    NSArray* categoriesArray = [[HAQuizDataManager sharedManager] quizCategoriesRequirePurchase];
    NSMutableSet*   productIdentifiers = [[NSMutableSet alloc] init];
    for (NSDictionary* categoryDict in categoriesArray)
    {
        if ([categoryDict objectForKey:kProductIdentifier]!=nil) {
            [productIdentifiers addObject:[categoryDict objectForKey:kProductIdentifier]];
        }
    }
    
    if ([HASettings sharedManager]._removeAdsProdcutIdentifier != nil) {
        [productIdentifiers addObject:[HASettings sharedManager]._removeAdsProdcutIdentifier];
    }
    
    self.productIdentifiers = productIdentifiers;

    return productIdentifiers;
}

- (void)loadProducts {
    AppDelegate* appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate showActivityIndicator];
    [[RageIAPHelper sharedInstance] setProductIdentifiers:[self identifiers]];
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        [appdelegate hideActivityIndicator];
        if (success) {
            self._products = products;
             [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductsLoadedNotification object:nil userInfo:nil];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductsFailedToLoadNotification object:nil userInfo:nil];
        }
    }];
}

- (NSString *)productPriceForProductIdentifier:(NSString *)productIndetifier
{
    NSNumberFormatter* priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    for (SKProduct* product in self._products) {
        if ([product.productIdentifier isEqualToString:productIndetifier]) {
            [priceFormatter setLocale:product.priceLocale];
            return [priceFormatter stringFromNumber:product.price];
        }
    }
    return nil;
}

- (BOOL)isProductPurchased:(NSString *)productIdentifier
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:productIdentifier] == nil) {
        return NO;
    }
    return YES;
}

- (BOOL)hasProduct:(NSString *)productIdentifier
{
    for (SKProduct * product in self._products) {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            if ([[NSUserDefaults standardUserDefaults] valueForKey:productIdentifier] == nil) {
                return YES;
            }
            NSLog(@"purchased productIdentifier : %@",productIdentifier);
            return NO;
        }
    }
    NSLog(@"Product identifier  \"%@\" might be wrong, please verify",productIdentifier);
    return NO;
}
@end
