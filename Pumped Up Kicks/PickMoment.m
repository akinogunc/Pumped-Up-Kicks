//
//  PickMoment.m
//  ThugLife
//
//  Created by AKIN OGUNC on 14/04/15.
//  Copyright (c) 2015 nebil. All rights reserved.
//

#import "PickMoment.h"
#import "GADMasterViewController.h"

@interface PickMoment (){
    UIImageView * thumb;
    AVURLAsset *asset;
    AVAssetImageGenerator *gen;
    UISlider *slider;
    UIView * v;

}

@end

@implementation PickMoment
@synthesize trimmedPath;
@synthesize delegate;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[GADMasterViewController singleton] resetAdView:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor blackColor];
    
    UIImageView * imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 50)];
    imageV.image = [UIImage imageNamed:@"topbar.png"];
    [self.view addSubview:imageV];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Home" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName: @"Avenir-Heavy" size: 20.0f];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.frame = CGRectMake(10.0, 10.0, 164.0/2.0, 60.0/2.0);
    [self.view addSubview:button];
    
    UIButton * button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"Next" forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont fontWithName: @"Avenir-Heavy" size: 20.0f];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button2.titleLabel.textAlignment = NSTextAlignmentLeft;
    button2.titleLabel.adjustsFontSizeToFitWidth = YES;
    button2.frame = CGRectMake(screenRect.size.width-95, 10.0, 170.0/2.0, 60.0/2.0);
    [self.view addSubview:button2];

    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        thumb = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-480)/2, (screenRect.size.height-480)/2, 480, 480)];
    }else{
        thumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenRect.size.height*0.17, screenRect.size.width, screenRect.size.width)];
    }

    [self.view addSubview:thumb];
    
    asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:trimmedPath] options:nil];
    gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.requestedTimeToleranceBefore = kCMTimeZero;
    gen.requestedTimeToleranceAfter = kCMTimeZero;
    gen.appliesPreferredTrackTransform = YES;
    
    
    CGRect frame;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        frame = CGRectMake(40.0,  screenRect.size.height*0.8, screenRect.size.width - 80, 20.0);
    }else{
        frame = CGRectMake(20.0,  screenRect.size.height*0.83, screenRect.size.width - 40, 20.0);
    }

    
    slider = [[UISlider alloc] initWithFrame:frame];
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor:[UIColor clearColor]];
    slider.minimumValue = 0.0;
    slider.maximumValue = 1.0;
    slider.continuous = YES;
    slider.value = 0.0;
    [self.view addSubview:slider];

    [self sliderAction:nil];
    
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
     
     v = [[UIView alloc] initWithFrame:screenRect];
     v.backgroundColor = [UIColor whiteColor];
        [v setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
     [self.view addSubview:v];
     
     UIImageView * im = [[UIImageView alloc] initWithFrame:screenRect];
     im.image = [UIImage imageNamed:@"puk_tutorial.png"];
        im.contentMode = UIViewContentModeScaleAspectFit;

     [v addSubview:im];
     
     UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
     [v addGestureRecognizer:singleFingerTap];
     
     }else{
     
     v = [[UIView alloc] initWithFrame:screenRect];
     v.backgroundColor = [UIColor whiteColor];
     [v setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
         
     [self.view addSubview:v];
     
     UIImageView * im = [[UIImageView alloc] initWithFrame:screenRect];
     im.image = [UIImage imageNamed:@"puk_tutorial.png"];
         im.contentMode = UIViewContentModeScaleAspectFit;
     [v addSubview:im];
     
     UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
     [v addGestureRecognizer:singleFingerTap];
     
     }

}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [v removeFromSuperview];
}

-(void)sliderAction:(id)sender
{
    float value = slider.value;
    
    NSError *error = nil;
    CMTime actualTime;
    
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    CMTime end = CMTimeMakeWithSeconds(durationSeconds*value, asset.duration.timescale);
    
    //NSLog(@"%f",durationSeconds*value);
    
    CGImageRef image = [gen copyCGImageAtTime:end actualTime:&actualTime error:&error];
    thumb.image = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)next{
    float value = slider.value;

    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    CMTime end = CMTimeMakeWithSeconds(durationSeconds*value, asset.duration.timescale);

    [self.delegate momentSelected:end];

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
