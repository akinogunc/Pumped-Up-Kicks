//
//  IGAssetsPickerViewController.h
//  InstagramAssetsPicker
//
//  Created by JG on 2/3/15.
//  Copyright (c) 2015 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@protocol IGAssetsPickerDelegate <NSObject>

//crop immediatly
-(void)IGAssetsPickerFinishCroppingToAsset:(NSDictionary *)dict;

@end

@interface IGAssetsPickerViewController : UIViewController
@property (nonatomic, strong) id<IGAssetsPickerDelegate> delegate;
@property int mode;
@property (readwrite, nonatomic) PHFetchOptions *fetchOptions;

@end

