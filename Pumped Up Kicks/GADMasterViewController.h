//
//  GADMasterViewController.h
//  ThugLife
//
//  Created by AKIN OGUNC on 26/01/15.
//  Copyright (c) 2015 nebil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface GADMasterViewController : UIViewController <GADBannerViewDelegate>{
    GADBannerView *adBanner_;
    BOOL didCloseWebsiteView_;
    BOOL isLoaded_;
    id currentDelegate_;
}

+(GADMasterViewController *)singleton;
-(void)resetAdView:(UIViewController *)rootViewController;
-(void)removeAds;

@end