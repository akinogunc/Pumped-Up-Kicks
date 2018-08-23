//
//  AppDelegate.h
//  Pumped Up Kicks
//
//  Created by Maruf Nebil Ogunc on 31.05.2018.
//  Copyright © 2018 Maruf Nebil Ogunc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GADInterstitialDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) GADInterstitial *interstitial;

-(void)showInterstitialFromVC:(UIViewController*)VC;

@end

