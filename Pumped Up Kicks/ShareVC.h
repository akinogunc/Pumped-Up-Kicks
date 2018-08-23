//
//  ShareVC.h
//  ThugLife
//
//  Created by AKIN OGUNC on 26/01/15.
//  Copyright (c) 2015 nebil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"
#import <Social/Social.h>
#import "MBProgressHUD.h"

@interface ShareVC : UIViewController<UIAlertViewDelegate,UIDocumentInteractionControllerDelegate,UIActionSheetDelegate>

@property(strong, nonatomic) UIDocumentInteractionController *dicont;
@property (strong, nonatomic) NSArray *_products;

@end
