//
//  HomeViewController.m
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import "HomeViewController.h"
#import "PBJViewController.h"
#import "IGAssetsPicker.h"
#import "TrimVideo.h"
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ShareVC.h"
#import "GADMasterViewController.h"
#import "RageIAPHelper.h"
#import "PickMoment.h"
#import "ShareVC.h"

@import Photos;
@import CoreText;

@interface HomeViewController ()<PBJViewControllerDelegate, IGAssetsPickerDelegate, TrimVideoDelegate, PickMomentDelegate>{
    
    AVAudioPlayer * player;
    NSString *rawVideoPath;
    UIImage *thugImage;
    MBProgressHUD *hud;
    int _currentColorHue;
    UIView * v;
    
}

@end

@implementation HomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenRect.size.width - 346)/2, screenRect.size.height*0.1, 346, 50)];
    imageView.image = [UIImage imageNamed:@"title4.png"];
    [self.view addSubview:imageView];
    
    
    UIButton * select = [UIButton buttonWithType:UIButtonTypeSystem];
    [select addTarget:self action:@selector(cameraButton) forControlEvents:UIControlEventTouchUpInside];
    [select setTitle:@"Record" forState:UIControlStateNormal];
    select.titleLabel.font = [UIFont fontWithName: @"Avenir-Heavy" size: 24.0f];
    [select setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    select.titleLabel.textAlignment = NSTextAlignmentLeft;
    select.frame = CGRectMake((screenRect.size.width-100)/2, screenRect.size.height*0.5, 100, 40);
    select.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:select];
    
    
    UIButton * select2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [select2 addTarget:self action:@selector(galleryButton) forControlEvents:UIControlEventTouchUpInside];
    [select2 setTitle:@"Gallery" forState:UIControlStateNormal];
    select2.titleLabel.font = [UIFont fontWithName: @"Avenir-Heavy" size: 24.0f];
    [select2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    select2.titleLabel.textAlignment = NSTextAlignmentLeft;
    select2.frame = CGRectMake((screenRect.size.width-100)/2, screenRect.size.height*0.5 + 60, 100, 40);
    select2.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:select2];
    
    UIButton * select3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [select3 addTarget:self action:@selector(restorePurchase) forControlEvents:UIControlEventTouchUpInside];
    [select3 setTitle:@"Restore" forState:UIControlStateNormal];
    select3.titleLabel.font = [UIFont fontWithName: @"Avenir-Heavy" size: 24.0f];
    [select3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    select3.titleLabel.textAlignment = NSTextAlignmentLeft;
    select3.frame = CGRectMake((screenRect.size.width-100)/2, screenRect.size.height*0.5 + 120, 100, 40);
    select3.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:select3];
    
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"puk" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:pathURL error:NULL];
    [player setVolume:0.7];
    //[player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreFailed:) name:IAPHelperRestoreFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreFinished:) name:IAPHelperRestoreFinishedNotification object:nil];

}

-(void)viewDidAppear:(BOOL)animated{
    
 /*   int first = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"firstopen"];
    
    if (first == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"firstopen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Welcome" message:@"Would you like watch the example video to get an idea about the app?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Watch" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showYoutube];
        }];
        [alertController addAction:settingsAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }*/

}

-(void)showYoutube{
    [player stop];

    CGRect screenRect = [[UIScreen mainScreen] bounds];

    v = [[UIView alloc] initWithFrame:screenRect];
    [v setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [self.view addSubview:v];

     NSURL *url = [NSURL URLWithString:@"http://www.youtube.com/watch?v=ZtMs4HTZHf8"];
     NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    CGRect frame;
    CGRect frame2;

    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.width);
        frame2 = CGRectMake(0, screenRect.size.height*0.04 + screenRect.size.width, screenRect.size.width, screenRect.size.height*0.1);
    }else{
        frame = CGRectMake(0, screenRect.size.height*0.2, screenRect.size.width, screenRect.size.width);
        frame2 = CGRectMake(0, screenRect.size.height*0.24 + screenRect.size.width, screenRect.size.width, screenRect.size.height*0.1);
    }

     UIWebView * videoWebView = [[UIWebView alloc] initWithFrame:frame];
     [videoWebView loadRequest:request];
     [videoWebView setNeedsLayout];
     [videoWebView setAllowsInlineMediaPlayback:YES];
     videoWebView.mediaPlaybackRequiresUserAction = NO;
     videoWebView.scrollView.scrollEnabled = NO;
     videoWebView.scrollView.bounces = NO;
     [v addSubview:videoWebView];

    UILabel * _instructionLabel = [[UILabel alloc] initWithFrame:frame2];
    _instructionLabel.textAlignment = NSTextAlignmentCenter;
    _instructionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
    _instructionLabel.textColor = [UIColor whiteColor];
    _instructionLabel.backgroundColor = [UIColor clearColor];
    _instructionLabel.text = @"Tap here to close";
    [v addSubview:_instructionLabel];

    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [v addGestureRecognizer:singleFingerTap];

}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [v removeFromSuperview];
}

-(void)cameraButton{
    [player stop];
    
    PBJViewController *PBJcamera = [[PBJViewController alloc] init];
    PBJcamera.delegate = self;
    [self presentViewController:PBJcamera animated:YES completion:NULL];
    
}

-(void)galleryButton{
    [player stop];
    
    IGAssetsPickerViewController *picker = [[IGAssetsPickerViewController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

-(void)IGAssetsPickerFinishCroppingToAsset:(NSDictionary*)dict
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self dismissViewControllerAnimated:YES completion:^(){
            
            //[hud2 hide:YES];
            
            if ([[dict objectForKey:@"type"]isEqualToString:@"video"]) {
                
                if ([[dict objectForKey:@"result"]isEqualToString:@"success"]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //NSString *croppedURL = NSTemporaryDirectory();
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *croppedURL = [paths firstObject];
                        
                        croppedURL = [croppedURL stringByAppendingPathComponent:@"cropped.mov"];
                        
                        TrimVideo * svc = [[TrimVideo alloc] init];
                        svc.delegate = self;
                        svc.croppedPath = croppedURL;
                        [self presentViewController:svc animated:YES completion:nil];
                        
                    });
                    
                    
                }else{
                    
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Can't use this video." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    
                    [self presentViewController:alertController animated:YES completion:nil];

                    
                }
                
            }
            
            
        }];
        
    });
    
    
}

-(void)trimFinished{
    
    [self dismissViewControllerAnimated:YES completion:^(){
        
        //NSString *trimmedURL = NSTemporaryDirectory();
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *trimmedURL = [paths firstObject];
        
        trimmedURL = [trimmedURL stringByAppendingPathComponent:@"trimmed.mov"];
        rawVideoPath = trimmedURL;
        
        
        PickMoment * ps = [[PickMoment alloc] init];
        ps.delegate = self;
        ps.trimmedPath = trimmedURL;
        [self presentViewController:ps animated:YES completion:nil];

    }];

}

-(void)momentSelected:(CMTime)moment{
    
    [self splitFirstPart:rawVideoPath mode:1 moment:moment];

}


-(void)recordFinished:(NSString *)path{
    
    rawVideoPath = path;
    
    [self dismissViewControllerAnimated:YES completion:^(){
        
        [self splitFirstPart:path mode:0 moment:kCMTimeZero];

    }];
    
}


-(void)splitFirstPart:(NSString*)path mode:(int)mode moment:(CMTime)moment{
    
     hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
     hud.mode = MBProgressHUDModeDeterminate;
     hud.labelText = @"Preparing Video...";
     hud.progress = 0.0;
    
    
    NSURL *videoFileUrl = [NSURL fileURLWithPath:path];
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
    
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path2 = [paths2 firstObject];
    path2 = [path2 stringByAppendingPathComponent:@"part1.mov"];
    [self deleteTmpFile:path2];
    
    exportSession.outputURL = [NSURL fileURLWithPath:path2];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    if (mode == 0) {
        
        CMTime start = CMTimeMakeWithSeconds(0, anAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(15, anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;

    }else{
        
        CMTime start = CMTimeMakeWithSeconds(0, anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, moment);
        exportSession.timeRange = range;

    }
    
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:{
                NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                
                [hud hide:NO];
                
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Error S1" message:[NSString stringWithFormat:@"%@",exportSession.error] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];

                
                break;
            }
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            default:
                NSLog(@"splitting first 15 second success");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    hud.progress = 0.2;
                    [self splitSecondPart:path mode:mode moment:moment];
                    
                });
                
                break;
        }
    }];

}

-(void)splitSecondPart:(NSString*)path mode:(int)mode moment:(CMTime)moment{
    
    NSURL *videoFileUrl = [NSURL fileURLWithPath:path];
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
    
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path2 = [paths2 firstObject];
    path2 = [path2 stringByAppendingPathComponent:@"part2.mov"];
    [self deleteTmpFile:path2];
    
    exportSession.outputURL = [NSURL fileURLWithPath:path2];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    if (mode == 0) {
        
        CMTime start = CMTimeMakeWithSeconds(15, anAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(CMTimeGetSeconds([anAsset duration]), anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;

    }else{
        
        CMTime duration = CMTimeMakeWithSeconds(CMTimeGetSeconds([anAsset duration]), anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(moment, duration);
        exportSession.timeRange = range;
        
    }

    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:{
                NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                
                [hud hide:NO];
                
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Error S2" message:[NSString stringWithFormat:@"%@",exportSession.error] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];

                break;
            }
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            default:
                NSLog(@"splitting second part success");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    hud.progress = 0.4;
                    [self editSecondPart:mode moment:moment];
                    
                });
                
                break;
        }
    }];

}

-(void)editSecondPart:(int)mode moment:(CMTime)moment{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *trimmedURL = [paths firstObject];
    trimmedURL = [trimmedURL stringByAppendingPathComponent:@"part2.mov"];
    NSURL *videoFileUrl = [NSURL fileURLWithPath:trimmedURL];
    
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    if ([[anAsset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, anAsset.duration)
                                       ofTrack:[[anAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                        atTime:kCMTimeZero
                                         error:nil];
        
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [hud hide:NO];
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Error : S3" message:@"Please try again. If this problem happens consistently, use another video. The source video may be broken." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];

        });
        
        return;
        
    }
    
    
    ////////
    CGSize videoSize = compositionVideoTrack.naturalSize;
    
    
    CALayer *aLayer2 = [CALayer layer];
    aLayer2.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    //aLayer2.backgroundColor = [UIColor greenColor].CGColor;
    aLayer2.opacity = 0.3;
    
    NSMutableArray *colors = [NSMutableArray array];
    for (NSInteger hue = 0; hue <= 360; hue += 10) {
        
        UIColor *color;
        color = [UIColor colorWithHue:1.0 * hue / 360.0
                           saturation:1.0
                           brightness:1.0
                                alpha:1.0];
        [colors addObject:(id)[color CGColor]];
    }

    
    CAKeyframeAnimation *animation =[CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
    animation.duration = 0.5;
    animation.repeatCount=100;
    animation.autoreverses=YES;
    animation.values = colors;
    animation.calculationMode = kCAAnimationPaced;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
    [aLayer2 addAnimation:animation forKey:@"aaa"];


    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    //[parentLayer addSublayer:aLayer1];
    [parentLayer addSublayer:aLayer2];

    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    ///////
    
    AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exportSession.videoComposition = videoComp;
    
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths2 firstObject];
    path = [path stringByAppendingPathComponent:@"part2edited.mov"];
    [self deleteTmpFile:path];
    
    exportSession.outputURL = [NSURL fileURLWithPath:path];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:{
                NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                
                [hud hide:NO];
                
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Error : S3" message:[NSString stringWithFormat:@"%@",exportSession.error] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
                
                break;
            }
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            default:
                NSLog(@"editing second part success");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    hud.progress = 0.6;
                    [self mergeParts:mode moment:moment];
                    
                });
                
                break;
        }
    }];

}

-(void)mergeParts:(int)mode moment:(CMTime)moment{
    
    //NSString *outputURL = NSTemporaryDirectory();
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *part1 = [paths firstObject];
    NSString *part2 = [paths firstObject];
    
    part1 = [part1 stringByAppendingPathComponent:@"part1.mov"];
    part2 = [part2 stringByAppendingPathComponent:@"part2edited.mov"];
    
    AVURLAsset *asset1 = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:part1] options:nil];
    AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:part2] options:nil];
    
    AVAssetTrack *assetVideoTrack1 = [asset1 tracksWithMediaType:AVMediaTypeVideo][0];
    AVAssetTrack *assetVideoTrack2 = [asset2 tracksWithMediaType:AVMediaTypeVideo][0];
    
    
    
    
    
    CMTime insertionPoint1 = kCMTimeZero;
    CMTime insertionPoint2 = [asset1 duration];
    
    AVMutableComposition* comp = [AVMutableComposition composition];
    
    if(mode == 0){
        
        AVMutableCompositionTrack* comptrack = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [comptrack setPreferredTransform:assetVideoTrack1.preferredTransform];
        
        [comptrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset1 duration]) ofTrack:assetVideoTrack1 atTime:insertionPoint1 error:nil];
        [comptrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset2 duration]) ofTrack:assetVideoTrack2 atTime:insertionPoint2 error:nil];
        
        comptrack = [comp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        NSString * filePath = [[NSBundle mainBundle] pathForResource:@"puk_1" ofType:@"mp3"];
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
        
        AVMutableCompositionTrack *compositionAudioTrack1 = [comp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
                                        ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                         atTime:kCMTimeZero
                                          error:nil];
        
        NSString * filePath2 = [[NSBundle mainBundle] pathForResource:@"puk_2" ofType:@"mp3"];
        AVURLAsset* audioAsset2 = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:filePath2] options:nil];
        
        AVMutableCompositionTrack *compositionAudioTrack2 = [comp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset2.duration)
                                        ofTrack:[[audioAsset2 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                         atTime:insertionPoint2
                                          error:nil];

    }else{
        
        CMTime start;
        CMTime start2;
        CMTime start3;

        if(CMTimeGetSeconds([asset1 duration]) >= 15){
            
            start = CMTimeMakeWithSeconds(CMTimeGetSeconds([asset1 duration])-15, asset1.duration.timescale);
            start2 = kCMTimeZero;
            insertionPoint2 = CMTimeMakeWithSeconds(15, asset1.duration.timescale);
            
        }else{
            
            start = kCMTimeZero;
            start2 = CMTimeMakeWithSeconds(15 - CMTimeGetSeconds([asset1 duration]), asset1.duration.timescale);

        }
        
        if(CMTimeGetSeconds([asset2 duration]) >= 15){

            start3 = CMTimeMakeWithSeconds(15, asset2.duration.timescale);
            
        }else{

            start3 = CMTimeMakeWithSeconds(CMTimeGetSeconds([asset2 duration]) - 0.2, asset2.duration.timescale);
            
        }

        
        AVMutableCompositionTrack* comptrack = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [comptrack setPreferredTransform:assetVideoTrack1.preferredTransform];
        
        [comptrack insertTimeRange:CMTimeRangeMake(start, [asset1 duration]) ofTrack:assetVideoTrack1 atTime:insertionPoint1 error:nil];
        [comptrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, start3) ofTrack:assetVideoTrack2 atTime:insertionPoint2 error:nil];
        
        
        
        
        
        NSString * filePath = [[NSBundle mainBundle] pathForResource:@"puk_1" ofType:@"mp3"];
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
        
        AVMutableCompositionTrack *compositionAudioTrack1 = [comp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(start2, audioAsset.duration)
                                        ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                         atTime:kCMTimeZero
                                          error:nil];
        
        NSString * filePath2 = [[NSBundle mainBundle] pathForResource:@"puk_2" ofType:@"mp3"];
        AVURLAsset* audioAsset2 = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:filePath2] options:nil];
        
        AVMutableCompositionTrack *compositionAudioTrack2 = [comp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
       [compositionAudioTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, start3)
                                        ofTrack:[[audioAsset2 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                         atTime:insertionPoint2
                                          error:nil];

        

    }
    

    
    
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths2 firstObject];
    
    path = [path stringByAppendingPathComponent:@"merged.mov"];
    [self deleteTmpFile:path];
    
    AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:[comp copy] presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = [NSURL fileURLWithPath:path];
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    //exportSession.shouldOptimizeForNetworkUse = YES;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted:{
                NSLog(@"merge success");

                int pro = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"pro"];
                
                if (pro == 0) {
                    hud.progress = 0.8;
                    [self addWatermak];
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        hud.progress = 1.0;
                        [hud hide:YES];
                    });

                    [self performSelectorOnMainThread:@selector(showShare) withObject:nil waitUntilDone:YES];
                }
                
                break;
            }
            case AVAssetExportSessionStatusFailed:{
                NSLog(@"Failed:%@",exportSession.error);
                
                [hud hide:NO];
                
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Error : S4" message:[NSString stringWithFormat:@"%@",exportSession.error] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
                
                break;
            }
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@",exportSession.error);
                break;
            default:
                NSLog(@"ZA:%@",exportSession.error);
                break;
        }
    }];

}

-(void)addWatermak{
    
    //NSString *path = NSTemporaryDirectory();
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths firstObject];
    
    path = [path stringByAppendingPathComponent:@"merged.mov"];
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo  preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *clipVideoTrack = nil;
    
    if ([[videoAsset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [hud hide:NO];
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Error : S5" message:@"Please try again. If this problem happens consistently, use another video. The source video may be broken." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        });
        
        return;
        
    }
    
    if (clipVideoTrack != nil) {
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                       ofTrack:clipVideoTrack
                                        atTime:kCMTimeZero error:nil];
    }
    
    
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio  preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *clipAudioTrack = nil;
    
    if ([[videoAsset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        clipAudioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    }
    
    if (clipAudioTrack != nil) {
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                       ofTrack:clipAudioTrack
                                        atTime:kCMTimeZero error:nil];
    }
    
    if (clipVideoTrack != nil) {
        [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
    }
    
    CGSize videoSize = compositionVideoTrack.naturalSize;
    
    CATextLayer *TextLayer = [CATextLayer layer];
    TextLayer.frame = CGRectMake(0.0f, 0, videoSize.width, videoSize.height*0.1);
    TextLayer.bounds = CGRectMake(videoSize.width/72.0, -videoSize.width/72.0, videoSize.width, videoSize.height*0.1);
    TextLayer.string = @"Pumped Up Kicks";
    TextLayer.font = CTFontCreateWithName((CFStringRef)@"Metropolis-Bold", 40, nil);
    TextLayer.backgroundColor = [UIColor clearColor].CGColor;
    TextLayer.wrapped = YES;
    TextLayer.fontSize = videoSize.width/18.0;
    TextLayer.masksToBounds = YES;
    TextLayer.alignmentMode = kCAAlignmentRight;
    
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:TextLayer];
    
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];

    
    AVAssetExportSession * _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.videoComposition = videoComp;
    
    //NSString *path2 = NSTemporaryDirectory();
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path2 = [paths2 firstObject];
    
    path2 = [path2 stringByAppendingPathComponent:@"merged2.mov"];
    NSURL    *exportUrl = [NSURL fileURLWithPath:path2];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path2])
    {
        NSLog(@"exists");
        [[NSFileManager defaultManager] removeItemAtPath:path2 error:nil];
    }
    
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = exportUrl;
    //_assetExport.shouldOptimizeForNetworkUse = YES;
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void){
        switch (_assetExport.status) {
            case AVAssetExportSessionStatusCompleted:{
                NSLog(@"watermark success");
                
                hud.progress = 1.0;
                [hud hide:YES];
                [self performSelectorOnMainThread:@selector(showShare) withObject:nil waitUntilDone:YES];
                //[self saveVideo:path2];

                break;
            }
            case AVAssetExportSessionStatusFailed:{
                
                [hud hide:NO];
                NSLog(@"Failed:%@",_assetExport.error);
                
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Error : S5" message:[NSString stringWithFormat:@"%@",_assetExport.error] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];

                
                break;
            }
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@",_assetExport.error);
                break;
            default:
                NSLog(@"ZA:%@",_assetExport.error);
                break;
        }
    }];
    
    
}

-(void)showShare{
    ShareVC * svc = [[ShareVC alloc] init];
    [self presentViewController:svc animated:YES completion:nil];
}

-(void)saveVideo:(NSString*)path{

    [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
        if ( status == PHAuthorizationStatusAuthorized ) {
            // Save the movie file to the photo library and cleanup.
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                
                options.shouldMoveFile = NO;
                PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                [creationRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:[NSURL fileURLWithPath:path] options:options];
            } completionHandler:^( BOOL success, NSError *error ) {
                if (success) {
                    NSLog(@"Saved movie to photo library: %@", error);
                }
            }];
        } else {
        }
    }];
    

}

-(void)deleteTmpFile:(NSString*)path{
    
    NSURL *url = [NSURL fileURLWithPath:path];
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

-(void)restorePurchase{
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading...";
    
    [[RageIAPHelper sharedInstance] restoreCompletedTransactions];
    
}

- (void)restoreFailed:(NSNotification *)notification {
    [hud hide:YES];
}

- (void)restoreFinished:(NSNotification *)notification {
    
    NSDictionary *dict = [notification userInfo];
    
    NSLog(@"Store scene %@",[dict objectForKey:@"restore"]);
    
    NSMutableArray * a = [dict objectForKey:@"restore"];
    
    
    for (int i = 0; i < a.count; i++) {
        
        if ([[a objectAtIndex:i] isEqualToString:@"puk_pro"]) {
            
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"pro"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[GADMasterViewController singleton] removeAds];
            
        }
        
    }
    
    [hud hide:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[GADMasterViewController singleton] resetAdView:self];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
