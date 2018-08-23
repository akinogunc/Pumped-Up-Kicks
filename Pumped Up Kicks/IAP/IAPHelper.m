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

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperFailedNotification = @"IAPHelperFailedNotification";
NSString *const IAPHelperRestoreFinishedNotification = @"IAPHelperRestoreFinishedNotification";
NSString *const IAPHelperRestoreFailedNotification = @"IAPHelperRestoreFailedNotification";

// 2
@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

// 3
@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
    
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    
    // 1
    _completionHandler = [completionHandler copy];
    
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying(2) %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        /*NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);*/
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
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
    NSLog(@"completeTransaction...");
    
    //[self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:transaction.payment.productIdentifier userInfo:nil];

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSMutableArray * a =[[NSMutableArray alloc] init];
    
    for (int i = 0; i<[queue transactions].count; i++) {
        SKPaymentTransaction * t = [[queue transactions] objectAtIndex:i];
        NSLog(@"Restored : %@",t.originalTransaction.payment.productIdentifier);
        
        //NSString *productID = t.originalTransaction.payment.productIdentifier;

        //if (!productID) {
            [a addObject:t.originalTransaction.payment.productIdentifier];
        //}

    }
    
    if ([queue transactions].count == 0) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperRestoreFailedNotification object:nil userInfo:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nothing to restore"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        NSDictionary * d = [[NSDictionary alloc] initWithObjectsAndKeys:a,@"restore", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperRestoreFinishedNotification object:nil userInfo:d];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Successful"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperRestoreFailedNotification object:nil userInfo:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction Error"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperFailedNotification object:transaction.payment.productIdentifier userInfo:nil];

    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction Error"
                                                        message:transaction.error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    NSLog(@"ff : %@",productIdentifier);
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
