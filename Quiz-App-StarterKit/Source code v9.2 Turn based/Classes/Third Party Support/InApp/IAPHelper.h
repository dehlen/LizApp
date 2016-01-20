//
//  IAPHelper.h


#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductsLoadedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductsFailedToLoadNotification;
//UIKIT_EXTERN NSString *const IAPHelperTransactionsRestoredNotification;


typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject
@property (nonatomic, strong) NSArray* _receivedProducts;
@property (nonatomic, strong) NSSet * _productIdentifiers;
@property (nonatomic, strong) RequestProductsCompletionHandler _completionHandler;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
- (void)setProductIdentifiers:(NSSet *)productIdentifiers;
@end