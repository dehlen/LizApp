//
//  RageIAPHelper.h

#import "IAPHelper.h"

@interface RageIAPHelper : IAPHelper

@property (nonatomic, strong) NSArray* _products;
@property (nonatomic, strong) NSSet* _productIdentifiers;
+ (RageIAPHelper *)sharedInstance;
- (void)loadProducts;
- (NSString *)productPriceForProductIdentifier:(NSString *)productIndetifier;
- (BOOL)hasProduct:(NSString *)productIdentifier;
- (NSSet *)identifiers;
- (BOOL)isProductPurchased:(NSString *)productIdentifier;
@end
