//
//  TrimVideo.m
//  ThugLife
//
//  Created by AKIN OGUNC on 15/04/15.
//  Copyright (c) 2015 nebil. All rights reserved.
//

#import "TrimVideo.h"
#import "GADMasterViewController.h"

@interface TrimVideo (){
    UIImageView * thumb;
    AVURLAsset *asset;
    AVAssetImageGenerator *gen;
    UIButton * play;
    UIView *movieView; // this should point to a view where the movie will play
    UIView * v;
    AVPlayer *videoPlayer;
    AVPlayerItem* playerItem;

}

@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;

@end

@implementation TrimVideo
@synthesize delegate;
@synthesize croppedPath,wastedMod,shitMod;

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

    
    
    self.mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(0, screenRect.size.height*0.1, self.view.frame.size.width, 60) videoUrl:[NSURL fileURLWithPath:croppedPath]];
    self.mySAVideoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
    [self.mySAVideoRangeSlider setPopoverBubbleSize:120 height:60];

    self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
    self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
    self.mySAVideoRangeSlider.delegate = self;
    [self.view addSubview:self.mySAVideoRangeSlider];

    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        thumb = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-480)/2, 120 + (self.view.frame.size.height - 210 - 480)/2, 480, 480)];
    }else{
        thumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80 + (self.view.frame.size.height - 170 - 320)/2, self.view.frame.size.width, self.view.frame.size.width)];
    }

    [self.view addSubview:thumb];
    
    asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:croppedPath] options:nil];
    gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.requestedTimeToleranceBefore = kCMTimeZero;
    gen.requestedTimeToleranceAfter = kCMTimeZero;
    gen.appliesPreferredTrackTransform = YES;

    NSError *error = nil;
    CMTime actualTime;
    
    CMTime end = CMTimeMakeWithSeconds(0, asset.duration.timescale);
    
    CGImageRef image = [gen copyCGImageAtTime:end actualTime:&actualTime error:&error];
    thumb.image = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);

    ////movie player
    
    movieView = [[UIView alloc] initWithFrame:thumb.frame];
    movieView.hidden = YES;
    [self.view addSubview:movieView];
    
    
    
    playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:croppedPath]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
    AVPlayerLayer *layer = [AVPlayerLayer layer];
    [layer setPlayer:videoPlayer];
    [layer setFrame:movieView.bounds];
    [layer setBackgroundColor:[UIColor blackColor].CGColor];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [movieView.layer addSublayer:layer];

    
    
    
    //white play video button
    play = [UIButton buttonWithType:UIButtonTypeCustom];
    [play addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [play setImage:[UIImage imageNamed:@"play2.png"] forState:UIControlStateNormal];
    play.frame = CGRectMake(0, 0, 64, 64);
    play.center = thumb.center;
    [self.view addSubview:play];

    
    
    if (self.stopTime == 0) {
        self.stopTime = CMTimeGetSeconds(asset.duration) - 0.2;
    }

}


-(void)play{
    
    play.hidden = YES;
    movieView.hidden = NO;
    
    Float64 dur = CMTimeGetSeconds(playerItem.duration);
    int32_t timeScale = playerItem.duration.timescale;

    if (self.stopTime == 0) {
        self.stopTime = dur;
    }
    
    [playerItem seekToTime:CMTimeMakeWithSeconds(self.startTime, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    playerItem.forwardPlaybackEndTime = CMTimeMakeWithSeconds(self.stopTime, timeScale);
    [videoPlayer play];

}

-(void)stop{
    play.hidden = NO;
    movieView.hidden = YES;
    [videoPlayer pause];
}


-(void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition{

    if((videoPlayer.rate != 0) && (videoPlayer.error == nil))
    {
        play.hidden = NO;
        movieView.hidden = YES;
        [videoPlayer pause];
    }
    
    NSError *error = nil;
    CMTime actualTime;
    
    CMTime end = CMTimeMakeWithSeconds(leftPosition, asset.duration.timescale);
    
    CGImageRef image = [gen copyCGImageAtTime:end actualTime:&actualTime error:&error];
    thumb.image = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);

    self.startTime = leftPosition;

}

-(void)videoRange:(SAVideoRangeSlider *)videoRange didChangeRightPosition:(CGFloat)rightPosition{
    //NSLog(@"-------%f",rightPosition);
    rightPosition = rightPosition - 0.2;
    //NSLog(@"--2----%f",rightPosition);

    if((videoPlayer.rate != 0) && (videoPlayer.error == nil))
    {
        play.hidden = NO;
        movieView.hidden = YES;
        [videoPlayer pause];
    }

    NSError *error = nil;
    CMTime actualTime;
    
    CMTime end = CMTimeMakeWithSeconds(rightPosition, asset.duration.timescale);
    
    CGImageRef image = [gen copyCGImageAtTime:end actualTime:&actualTime error:&error];
    thumb.image = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);

    self.stopTime = rightPosition;

}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)next{
    
    [self deleteTmpFile];
    
    NSURL *videoFileUrl = [NSURL fileURLWithPath:croppedPath];
    
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
    
    //NSString *trimmedURL = NSTemporaryDirectory();
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *trimmedURL = [paths firstObject];
    
    trimmedURL = [trimmedURL stringByAppendingPathComponent:@"trimmed.mov"];
    NSURL *furl = [NSURL fileURLWithPath:trimmedURL];
    
    exportSession.outputURL = furl;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    CMTime start = CMTimeMakeWithSeconds(self.startTime, anAsset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(self.stopTime-self.startTime, anAsset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            default:
                NSLog(@"NONE");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.delegate trimFinished];
                    
                });
                
                break;
        }
    }];

}


-(void)deleteTmpFile{
    
    //NSString *trimmedURL = NSTemporaryDirectory();
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *trimmedURL = [paths firstObject];

    trimmedURL = [trimmedURL stringByAppendingPathComponent:@"trimmed.mov"];

    NSURL *url = [NSURL fileURLWithPath:trimmedURL];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
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
