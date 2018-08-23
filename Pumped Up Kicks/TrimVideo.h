//
//  TrimVideo.h
//  ThugLife
//
//  Created by AKIN OGUNC on 15/04/15.
//  Copyright (c) 2015 nebil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAVideoRangeSlider.h"

@class TrimVideo;

@protocol TrimVideoDelegate <NSObject>
-(void)trimFinished;
@end

@interface TrimVideo : UIViewController <SAVideoRangeSliderDelegate>

@property (nonatomic, weak) id <TrimVideoDelegate> delegate;
@property (strong, nonatomic) NSString * croppedPath;
@property int wastedMod;
@property int shitMod;

@end
