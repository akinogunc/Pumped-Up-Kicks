//
//  ShareVC.m
//  ThugLife
//
//  Created by AKIN OGUNC on 26/01/15.
//  Copyright (c) 2015 nebil. All rights reserved.
//

#import "ShareVC.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import <Social/Social.h>
#import <Photos/Photos.h>
#import "GADMasterViewController.h"
#import "RageIAPHelper.h"

@interface ShareVC (){
    AVAudioPlayer * player;
    UIButton * play;
    AVQueuePlayer *videoPlayer;
    AVPlayerItem* playerItem;
    
    BOOL shareOpen;
    MBProgressHUD *hud;
    UIView * shareBg;
    UIView * shareBg2;
    MBProgressHUD *hud2;
    UIButton * button2;
    
}
@end

@implementation ShareVC
@synthesize dicont;
@synthesize _products;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[GADMasterViewController singleton] resetAdView:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //constants
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Home" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName: @"Avenir-Heavy" size: 20.0f];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.frame = CGRectMake(10.0, 10.0, 164.0/2.0, 60.0/2.0);
    [self.view addSubview:button];
    
    UIButton * button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"Share" forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont fontWithName: @"Avenir-Heavy" size: 20.0f];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button1.titleLabel.textAlignment = NSTextAlignmentLeft;
    button1.titleLabel.adjustsFontSizeToFitWidth = YES;
    button1.frame = CGRectMake(screenRect.size.width-95, 10.0, 170.0/2.0, 60.0/2.0);
    [self.view addSubview:button1];

    
    //video player
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths firstObject];
    
    int pro = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"pro"];
    
    if (pro == 0) {
        path = [path stringByAppendingPathComponent:@"merged2.mov"];
    }else{
        path = [path stringByAppendingPathComponent:@"merged.mov"];
    }

    
    playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:path]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    videoPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:playerItem];
    
    AVPlayerLayer *layer = [AVPlayerLayer layer];
    [layer setPlayer:videoPlayer];
    
    int ipadOffset = 0;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        [layer setFrame:CGRectMake((screenRect.size.width-480)/2, 100, 480, 480)];
        ipadOffset = 60;
    }else{
        [layer setFrame:CGRectMake(0, 70, screenRect.size.width, screenRect.size.width)];
    }
    
    [layer setBackgroundColor:[UIColor blackColor].CGColor];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.view.layer addSublayer:layer];
    
    //white play video button
    play = [UIButton buttonWithType:UIButtonTypeCustom];
    [play addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [play setImage:[UIImage imageNamed:@"play2.png"] forState:UIControlStateNormal];
    play.frame = CGRectMake(0, 0, 64, 64);
    play.center =  CGPointMake(layer.frame.origin.x + layer.bounds.size.width / 2.0, layer.frame.origin.y + layer.bounds.size.height / 2.0);
    [self.view addSubview:play];
    
    
    if (pro == 0) {
        button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [button2 addTarget:self action:@selector(UnlockPro) forControlEvents:UIControlEventTouchUpInside];
        [button2 setTitle:@"Remove Watermark and Ads" forState:UIControlStateNormal];
        [button2 setBackgroundColor:[UIColor colorWithRed:72.0/255.0 green:207.0/255.0 blue:132.0/255.0 alpha:1]];
        button2.titleLabel.font = [UIFont fontWithName: @"Avenir-Heavy" size: 20.0f];
        [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button2.titleLabel.textAlignment = NSTextAlignmentLeft;
        button2.titleLabel.adjustsFontSizeToFitWidth = YES;
        button2.frame = CGRectMake(0, layer.frame.origin.y + layer.bounds.size.height + 40 + ipadOffset, screenRect.size.width, screenRect.size.height*0.07);
        [self.view addSubview:button2];
    }

    
    UIButton * button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 addTarget:self action:@selector(rateApp) forControlEvents:UIControlEventTouchUpInside];
    [button3 setTitle:@"Rate App" forState:UIControlStateNormal];
    [button3 setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:199.0/255.0 blue:54.0/255.0 alpha:1]];
    button3.titleLabel.font = [UIFont fontWithName: @"Avenir-Heavy" size: 20.0f];
    [button3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button3.titleLabel.textAlignment = NSTextAlignmentLeft;
    button3.titleLabel.adjustsFontSizeToFitWidth = YES;
    button3.frame = CGRectMake(0, layer.frame.origin.y + layer.bounds.size.height + 60 + screenRect.size.height*0.07 + ipadOffset, screenRect.size.width, screenRect.size.height*0.07);
    [self.view addSubview:button3];

    
    [self loadProducts];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productFailed:) name:IAPHelperFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreFailed:) name:IAPHelperRestoreFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreFinished:) name:IAPHelperRestoreFinishedNotification object:nil];

}

-(void)loadProducts{
    
    _products = nil;
    
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        
        if (success) {
            _products = products;
            
            for (int i = 0; i<products.count; i++) {
                SKProduct *product = (SKProduct *) _products[i];
                
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [numberFormatter setLocale:product.priceLocale];
                //NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
                
                NSLog(@"Found product: %@ %@ %0.2f", product.productIdentifier, product.localizedTitle, product.price.floatValue);
                
            }
            
        }else{
            
            
            NSLog(@"Can't load products");
            
        }
    }];
    
}

-(void)UnlockPro{
    
    for (SKProduct *product in _products) {
        if ([product.productIdentifier isEqualToString:@"puk_pro"]) {
            
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"Loading...";

            [[RageIAPHelper sharedInstance] buyProduct:product];
        }
    }
    
}

-(void)restorePurchase{
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading...";
    
    [[RageIAPHelper sharedInstance] restoreCompletedTransactions];
    
}

- (void)restoreFailed:(NSNotification *)notification {
    [hud hide:YES];
}

- (void)restoreFinished:(NSNotification *)notification {
    
    NSDictionary *dict = [notification userInfo];
    
    NSLog(@"Store scene %@",[dict objectForKey:@"restore"]);
    
    NSMutableArray * a = [dict objectForKey:@"restore"];
    
    
    for (int i = 0; i < a.count; i++) {
        
        if ([[a objectAtIndex:i] isEqualToString:@"puk_pro"]) {
            
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"pro"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
    
    [hud hide:YES];
}

- (void)productPurchased:(NSNotification *)notification {
    
    [hud hide:YES];
    
    NSString * productIdentifier = notification.object;
    NSLog(@"Bought %@...", productIdentifier);
    
    if ([productIdentifier isEqualToString:@"puk_pro"]) {
        
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"pro"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [button2 removeFromSuperview];
        [[GADMasterViewController singleton] removeAds];

        
        [videoPlayer removeAllItems];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths firstObject];
        path = [path stringByAppendingPathComponent:@"merged.mov"];
        playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:path]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [videoPlayer insertItem:playerItem afterItem:nil];
        [videoPlayer pause];

    }
    
}

- (void)productFailed:(NSNotification *)notification {
    [hud hide:YES];
}


-(void)rateApp{

    if([[UIDevice currentDevice].systemVersion floatValue] < 10.3f){
        static NSString *const iOS7AppStoreURLFormat = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iOS7AppStoreURLFormat]];
    }else{
        [SKStoreReviewController requestReview];
    }
    
}


-(void)play{
    play.hidden = YES;
    [playerItem seekToTime:kCMTimeZero];
    [videoPlayer play];
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    play.hidden = NO;
    
    [videoPlayer removeAllItems];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths firstObject];
    
    int pro = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"pro"];
    
    if (pro == 0) {
        path = [path stringByAppendingPathComponent:@"merged2.mov"];
    }else{
        path = [path stringByAppendingPathComponent:@"merged.mov"];
    }

    playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:path]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [videoPlayer insertItem:playerItem afterItem:nil];

    [videoPlayer pause];
}

-(void)back{
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"You will lose the video" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:settingsAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

-(void)share{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *videoFilePath = [paths firstObject];
    
    
    int pro = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"pro"];
    
    if (pro == 0) {
        videoFilePath = [videoFilePath stringByAppendingPathComponent:@"merged2.mov"];
    }else{
        videoFilePath = [videoFilePath stringByAppendingPathComponent:@"merged.mov"];
    }

    NSURL * url = [NSURL fileURLWithPath:videoFilePath];
    
    NSArray *activityItems = [NSArray arrayWithObjects:url,@"Made with Pumped Up Kicks app! #pumpedupkicks", nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        if (pro == 0) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showInterstitialFromVC:self];
        }else{
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Video Saved" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    };

    if ( [activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
        activityViewController.popoverPresentationController.sourceView = self.view;
    }
    
    [self presentViewController:activityViewController animated:YES completion:nil];

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
