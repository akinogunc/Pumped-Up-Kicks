//
//  IGCropView.h
//  InstagramAssetsPicker
//
//  Created by JG on 2/3/15.
//  Copyright (c) 2015 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface IGCropView : UIScrollView
@property (nonatomic, strong) PHAsset * phAsset;
    
- (void)cropAssetandCallback:(void (^)(NSDictionary *))callback;
- (void)stopVideoPlayer;

- (CGRect)getCropRegion;

//for lately crop
+(void)cropPhAsset:(PHAsset *)asset2 withRegion:(CGRect)rect onComplete:(void(^)(NSDictionary *))completion;

@end
