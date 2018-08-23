//
//  PBJViewController.m
//  PBJVision
//
//  Created by Patrick Piemonte on 7/23/13.
//  Copyright (c) 2013-present, Patrick Piemonte, http://patrickpiemonte.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "PBJViewController.h"
#import "PBJStrobeView.h"

#import "PBJVision.h"
#import "PBJVisionUtilities.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <GLKit/GLKit.h>

@interface ExtendedHitButton : UIButton

+ (instancetype)extendedHitButton;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end

@implementation ExtendedHitButton

+ (instancetype)extendedHitButton
{
    return (ExtendedHitButton *)[ExtendedHitButton buttonWithType:UIButtonTypeCustom];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect relativeFrame = self.bounds;
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-35, -35, -35, -35);
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

@end

@interface PBJViewController () <
    UIGestureRecognizerDelegate,
    PBJVisionDelegate,
    UIAlertViewDelegate, AVAudioPlayerDelegate>
{
    PBJStrobeView *_strobeView;
    UIButton *_doneButton;
    AVAudioPlayer * player;

    UIButton *_flipButton;
    UIButton *_focusButton;
    UIButton *_frameRateButton;
    UIButton *_onionButton;
    UIView *_captureDock;
    UIButton *_playButton;

    UIView *_previewView;
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    UILabel *_instructionLabel;
    UIView *_gestureView;
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    UITapGestureRecognizer *_focusTapGestureRecognizer;
    UITapGestureRecognizer *_photoTapGestureRecognizer;
    UILabel *timeElapsed;

    BOOL _recording;

    ALAssetsLibrary *_assetLibrary;
    __block NSDictionary *_currentVideo;
    __block NSDictionary *_currentPhoto;
}

@end

@implementation PBJViewController
@synthesize delegate;

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - init

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    _longPressGestureRecognizer.delegate = nil;
    _focusTapGestureRecognizer.delegate = nil;
    _photoTapGestureRecognizer.delegate = nil;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);

    // elapsed time and red dot
    _strobeView = [[PBJStrobeView alloc] initWithFrame:CGRectZero];
    CGRect strobeFrame = _strobeView.frame;
    strobeFrame.origin = CGPointMake(viewWidth/2 - 15.0f, 15.0f);
    _strobeView.frame = strobeFrame;
    [self.view addSubview:_strobeView];

    // time elapsed label
/*    timeElapsed = [[UILabel alloc] initWithFrame:self.view.bounds];
    timeElapsed.textAlignment = NSTextAlignmentCenter;
    timeElapsed.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    timeElapsed.textColor = [UIColor whiteColor];
    timeElapsed.backgroundColor = [UIColor clearColor];
    timeElapsed.text = @"00:00";
    timeElapsed.frame = CGRectMake((self.view.bounds.size.width-100)/2, _strobeView.frame.origin.y, 100, _strobeView.frame.size.height);
    [self.view addSubview:timeElapsed];*/

    // done button
    _doneButton = [ExtendedHitButton extendedHitButton];
    _doneButton.frame = CGRectMake(25.0f - 15.0f, 18.0f, 25.0f, 25.0f);
    UIImage *buttonImage = [UIImage imageNamed:@"back2.png"];
    [_doneButton setImage:buttonImage forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneButton];

    // preview and AV layer
    _previewView = [[UIView alloc] initWithFrame:CGRectZero];
    _previewView.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = CGRectMake(0, 60.0f, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame));
    _previewView.frame = previewFrame;
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    
    
    [[PBJVision sharedInstance] setPresentationFrame:_previewView.frame];

    // instruction label
    _instructionLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    _instructionLabel.textAlignment = NSTextAlignmentCenter;
    _instructionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    _instructionLabel.textColor = [UIColor whiteColor];
    _instructionLabel.backgroundColor = [UIColor blackColor];
    _instructionLabel.text = NSLocalizedString(@"Press Play to start recording", @"Instruction message for capturing video.");
    [_instructionLabel sizeToFit];
    CGPoint labelCenter = _previewView.center;
    labelCenter.y += ((CGRectGetHeight(_previewView.frame) * 0.5f) + 35.0f);
    _instructionLabel.center = labelCenter;
    [self.view addSubview:_instructionLabel];
    
/*    // touch to record
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGestureRecognizer:)];
    _longPressGestureRecognizer.delegate = self;
    _longPressGestureRecognizer.minimumPressDuration = 0.05f;
    _longPressGestureRecognizer.allowableMovement = 10.0f;
    
    
    // gesture view to record
    _gestureView = [[UIView alloc] initWithFrame:CGRectZero];
    CGRect gestureFrame = self.view.bounds;
    gestureFrame.origin = CGPointMake(0, 60.0f);
    gestureFrame.size.height -= (40.0f + 85.0f);
    _gestureView.frame = gestureFrame;
    [self.view addSubview:_gestureView];
    
    [_gestureView addGestureRecognizer:_longPressGestureRecognizer];*/

    // bottom dock
/*    _captureDock = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 60.0f, CGRectGetWidth(self.view.bounds), 60.0f)];
    _captureDock.backgroundColor = [UIColor clearColor];
    _captureDock.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_captureDock];*/
    
    // flip button
    _flipButton = [ExtendedHitButton extendedHitButton];
    _flipButton.frame = CGRectMake(viewWidth - 36.0f - 15.0f, 15.0f, 36, 30);
    UIImage *flipImage = [UIImage imageNamed:@"capture_flip"];
    [_flipButton setImage:flipImage forState:UIControlStateNormal];
    [_flipButton addTarget:self action:@selector(_handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flipButton];
    
    // play button
    _playButton = [ExtendedHitButton extendedHitButton];
    _playButton.frame = CGRectMake(viewWidth/2 - 32.0f , labelCenter.y + 40.0f, 64, 64);
    [_playButton setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(_startCapture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];

    NSString *path  = [[NSBundle mainBundle] pathForResource:@"puk" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:pathURL error:NULL];
    player.delegate = self;
    [player setVolume:1.0];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // iOS 6 support
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [self _resetCapture];
    [[PBJVision sharedInstance] startPreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PBJVision sharedInstance] stopPreview];
    
    // iOS 6 support
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - private start/stop helper methods

- (void)_startCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 0;
        _instructionLabel.transform = CGAffineTransformMakeTranslation(0, 10.0f);
    } completion:^(BOOL finished) {
    }];
    
    _playButton.hidden = YES;
    
    [player play];
    [[PBJVision sharedInstance] startVideoCapture];

}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self _endCapture];
}

- (void)_endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
}

- (void)_resetCapture
{
    [_strobeView stop];
    _longPressGestureRecognizer.enabled = YES;

    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;

    if ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        vision.cameraDevice = PBJCameraDeviceBack;
        _flipButton.hidden = NO;
    } else {
        vision.cameraDevice = PBJCameraDeviceFront;
        _flipButton.hidden = YES;
    }
    
    vision.cameraMode = PBJCameraModeVideo;
    //vision.cameraMode = PBJCameraModePhoto; // PHOTO: uncomment to test photo capture
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatSquare;
    vision.videoRenderingEnabled = YES;
    //vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30}; //AVVideoProfileLevelKey requires specific captureSessionPreset
    
    vision.captureSessionPreset = AVCaptureSessionPreset640x480;
    
    
    // specify a maximum duration with the following property
    // vision.maximumCaptureDuration = CMTimeMakeWithSeconds(5, 600); // ~ 5 seconds
}

#pragma mark - UIButton

- (void)_handleFlipButton:(UIButton *)button
{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.cameraDevice = vision.cameraDevice == PBJCameraDeviceBack ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

- (void)_handleFrameRateChangeButton:(UIButton *)button
{
}

-(void)back{
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)_handleDoneButton:(UIButton *)button
{
    // resets long press
    _longPressGestureRecognizer.enabled = NO;
    _longPressGestureRecognizer.enabled = YES;
    
    [self _endCapture];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self _resetCapture];
}

#pragma mark - PBJVisionDelegate

// session

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    if (![_previewView superview]) {
        [self.view addSubview:_previewView];
        [self.view bringSubviewToFront:_gestureView];
    }
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
    [_previewView removeFromSuperview];
}

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did start");
    
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did stop");
}

// device

- (void)visionCameraDeviceWillChange:(PBJVision *)vision
{
    NSLog(@"Camera device will change");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision
{
    NSLog(@"Camera device did change");
}

// mode

- (void)visionCameraModeWillChange:(PBJVision *)vision
{
    NSLog(@"Camera mode will change");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision
{
    NSLog(@"Camera mode did change");
}

// format

- (void)visionOutputFormatWillChange:(PBJVision *)vision
{
    NSLog(@"Output format will change");
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision
{
    NSLog(@"Output format did change");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
}

// flash

- (void)visionDidChangeFlashMode:(PBJVision *)vision
{
    NSLog(@"Flash mode did change");
}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision
{
}

- (void)visionDidCapturePhoto:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
    if (error) {
        // handle error properly
        return;
    }
    _currentPhoto = photoDict;
    
    // save to library
    NSData *photoData = _currentPhoto[PBJVisionPhotoJPEGKey];
    NSDictionary *metadata = _currentPhoto[PBJVisionPhotoMetadataKey];
   [_assetLibrary writeImageDataToSavedPhotosAlbum:photoData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error1) {
        if (error1 || !assetURL) {
            // handle error properly
            return;
        }
       
        NSString *albumName = @"PBJVision";
        __block BOOL albumFound = NO;
        [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                albumFound = YES;
                [_assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    [group addAsset:asset];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Saved!" message: @"Saved to the camera roll."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
                    [alert show];
                } failureBlock:nil];
            }
            if (!group && !albumFound) {
                __weak ALAssetsLibrary *blockSafeLibrary = _assetLibrary;
                [_assetLibrary addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group1) {
                    [blockSafeLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group1 addAsset:asset];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Photo Saved!" message: @"Saved to the camera roll."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
                        [alert show];
                    } failureBlock:nil];
                } failureBlock:nil];
            }
        } failureBlock:nil];
    }];
    
    _currentPhoto = nil;
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    [_strobeView start];
    _recording = YES;
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
    [_strobeView stop];
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
    [_strobeView start];
}

#pragma mark save video
- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    _recording = NO;

    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }

    _currentVideo = videoDict;
    
    NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
    
    [self.delegate recordFinished:videoPath];

    /*[_assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Saved!" message: @"Saved to the camera roll."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }];*/
}

// progress

- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (vision.capturedVideoSeconds > 0) {
        int minutes = floor(vision.capturedVideoSeconds/60);
        int seconds = round(vision.capturedVideoSeconds - minutes * 60);
        
        timeElapsed.text = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    }
    
    //NSLog(@"captured video (%f) seconds", vision.capturedVideoSeconds);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer
{
//    NSLog(@"captured video (%f) seconds", vision.capturedVideoSeconds);
}

@end
