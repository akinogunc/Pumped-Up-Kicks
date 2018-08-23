//
//  PickMoment.h
//  ThugLife
//
//  Created by AKIN OGUNC on 14/04/15.
//  Copyright (c) 2015 nebil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class PickMoment;

@protocol PickMomentDelegate <NSObject>
-(void)momentSelected: (CMTime) moment;
@end

@interface PickMoment : UIViewController

@property(strong,nonatomic) NSString * trimmedPath;
@property (nonatomic, weak) id <PickMomentDelegate> delegate;

@end
