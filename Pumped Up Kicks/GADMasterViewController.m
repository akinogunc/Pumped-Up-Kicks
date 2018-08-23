//
//  GADMasterViewController.m
//  ThugLife
//
//  Created by AKIN OGUNC on 26/01/15.
//  Copyright (c) 2015 nebil. All rights reserved.
//

#import "GADMasterViewController.h"

@implementation GADMasterViewController

+(GADMasterViewController *)singleton {
    static dispatch_once_t pred;
    static GADMasterViewController *shared;
    // Will only be run once, the first time this is called
    dispatch_once(&pred, ^{
        shared = [[GADMasterViewController alloc] init];
    });
    return shared;
}

-(id)init {
    if (self = [super init]) {
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
            adBanner_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        }else{
            adBanner_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        }

        isLoaded_ = NO;
    }
    return self;
}

-(void)resetAdView:(UIViewController *)rootViewController {
    // Always keep track of currentDelegate for notification forwarding
    currentDelegate_ = rootViewController;
    
    int ads = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"pro"];

    if(ads == 0){
        // Ad already requested, simply add it into the view
        if (isLoaded_) {
            CGRect frame = adBanner_.frame;
            adBanner_.frame = CGRectMake(0, rootViewController.view.bounds.size.height-frame.size.height, frame.size.width, frame.size.height);
            
            [rootViewController.view addSubview:adBanner_];
        } else {
            
            adBanner_.delegate = self;
            adBanner_.rootViewController = rootViewController;
            adBanner_.adUnitID = @"ca-app-pub-6688307708468299/8933496179";
            
            GADRequest *request = [GADRequest request];
            request.testDevices = @[@"7525b3595d44a7ade44093663d160a59",@"263237cd12e8a4059275c3fd6c9683ef"];
            [adBanner_ loadRequest:request];
            
            CGRect frame = adBanner_.frame;
            adBanner_.frame = CGRectMake(0, rootViewController.view.bounds.size.height-frame.size.height, frame.size.width, frame.size.height);

            [rootViewController.view addSubview:adBanner_];
            isLoaded_ = YES;
        }

    }
}

-(void)removeAds{
    [adBanner_ removeFromSuperview];
}

@end
