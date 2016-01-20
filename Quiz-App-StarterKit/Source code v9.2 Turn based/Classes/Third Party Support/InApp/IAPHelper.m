//
//  IAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

// 1
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "AppDelegate.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const  IAPHelperProductsLoadedNotification = @"IAPHelperProductsLoadedNotification";
NSString *const IAPHelperProductsFailedToLoadNotification = @"IAPHelperProductsFailedToLoadNotification";

// 2
@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end
@implementation IAPHelper

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        self._productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
//        for (NSString * productIdentifier in self._productIdentifiers) {
//            BOOL productPurchased = [self productPurchased:productIdentifier];
//            if (productPurchased) {
//                NSLog(@"Previously purchased: %@", productIdentifier);
//            } else {
//                NSLog(@"Not purchased: %@", productIdentifier);
//            }
//        }
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)setProductIdentifiers:(NSSet *)productIdentifiers
{
    self._productIdentifiers = productIdentifiers;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    self._completionHandler = completionHandler;
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:self._productIdentifiers];
    request.delegate = self;
    [request start];
    
    NSLog(@"sent product identifiers : %@",self._productIdentifiers);
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:productIdentifier]) {
        return YES;        
    }
    return NO;
}

- (void)buyProduct:(SKProduct *)product {
    
    AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (![HAUtilities isInternetConnectionAvailable])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Device is not connected to Internet." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [delegate._navController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if (![self._productIdentifiers count])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Unable to buy at this time, please try later" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [delegate._navController presentViewController:alertController animated:YES completion:nil];
        return;
    }

    
    NSLog(@"Buying %@...", product.productIdentifier);
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate showActivityIndicator];
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products... : request : %@  response:%@ products : %@",request,response,response.products);
    self._receivedProducts = response.products;
    
    
    if (response.invalidProductIdentifiers.count) {
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Found invalid product identifiers : \"%@\". Please verify these in iTune's connect",response.invalidProductIdentifiers] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alertView show];
        return;
    }
    
    if (response.products.count == 0) {
        AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appdelegate hideActivityIndicator];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Products not loaded, please try later." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [appdelegate._navController presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");
    self._completionHandler(NO, nil);
    self._completionHandler = nil;
    request = nil;
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductsFailedToLoadNotification object:error];
}

- (void)requestDidFinish:(SKRequest *)request
{
//    for (SKProduct * skProduct in self._receivedProducts) {
//        NSLog(@"Found product: %@ %@ %0.2f",
//              skProduct.productIdentifier,
//              skProduct.localizedTitle,
//              skProduct.price.floatValue);
//    }
    
    if (self._receivedProducts.count)
    {
        self._completionHandler(YES, self._receivedProducts);
        self._completionHandler = nil;
    }
    request = nil;
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate hideActivityIndicator];
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    [[NSUserDefaults standardUserDefaults] setObject:transaction.payment.productIdentifier forKey:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:transaction.payment.productIdentifier];
    
    NSLog(@"completeTransaction...");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate hideActivityIndicator];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:transaction.payment.productIdentifier];

    [[NSUserDefaults standardUserDefaults] setObject:transaction.payment.productIdentifier forKey:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:transaction.payment.productIdentifier];

//    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperTransactionsRestoredNotification object:nil];
    NSLog(@"restoreTransaction...");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate hideActivityIndicator];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:transaction.error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [appdelegate._navController presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [appdelegate hideActivityIndicator];

//    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductsFailedToLoadNotification object:transaction.error];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end