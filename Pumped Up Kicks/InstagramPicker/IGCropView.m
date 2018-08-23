//
//  IGCropView.m
//  InstagramAssetsPicker
//
//  Created by JG on 2/3/15.
//  Copyright (c) 2015 JG. All rights reserved.
//

#import "IGCropView.h"

#define rad(angle) ((angle) / 180.0 * M_PI)


@interface IGCropView()<UIScrollViewDelegate>
{
    CGSize _imageSize;
    int _playState;//if is video(playing or pause) or image
    NSString * _type;
    PHAssetMediaType _mediaType;

}

@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (nonatomic) CGFloat videoPlayerScale;
@property (strong, nonatomic) UIImageView * videoStartMaskView;

@end

@implementation IGCropView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        

    }
    return self;
}



-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
    
    self.videoStartMaskView.hidden = YES;
    


}


-(UIImageView *)videoStartMaskView
{
    if(!_videoStartMaskView)
    {
        self.videoStartMaskView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InstagramAssetsPicker.bundle/Start"] ];
        //FIXME: should use constraint
        self.videoStartMaskView.frame = CGRectMake(self.superview.frame.size.width / 2 + self.superview.frame.origin.x - 25, self.superview.frame.size.height / 2 + self.superview.frame.origin.y - 25, 50, 50);
        [self.superview addSubview:self.videoStartMaskView];
        self.videoStartMaskView.hidden = YES;
    }
    return _videoStartMaskView;
}

-(CGRect)getCropRegion
{
    if (self.phAsset)
    {
        if (_mediaType == PHAssetResourceTypePhoto)
        {
            CGRect visibleRect = [self _calcVisibleRectForCropArea];//caculate visible rect for crop
            CGAffineTransform rectTransform = [self _orientationTransformedRectOfImage:self.imageView.image];//if need rotate caculate
            visibleRect = CGRectApplyAffineTransform(visibleRect, rectTransform);
            
            return visibleRect;
        }
        else if (_mediaType == PHAssetMediaTypeVideo)
        {
            CGRect visibleRect = [self convertRect:self.bounds toView:self.videoPlayer.view];
            
            CGAffineTransform t = CGAffineTransformMakeScale( 1 / self.videoPlayerScale, 1 / self.videoPlayerScale);
            
            visibleRect = CGRectApplyAffineTransform(visibleRect, t);
            
            return visibleRect;
        }
        else
            return CGRectNull;
    }
    else
        return CGRectNull;
}

-(void)stopVideoPlayer{
    
    if(self.videoPlayer)
    {
        [self.videoPlayer stop];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoPlayer.view removeFromSuperview];
        });
        
    }

}
- (void)cropAssetandCallback:(void (^)(NSDictionary *))callback
{

    [IGCropView cropPhAsset:self.phAsset withRegion:[self getCropRegion] onComplete:^(NSDictionary* result){
        
        callback((NSDictionary*) result);
        
        if(self.videoPlayer)
        {
            [self.videoPlayer stop];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.videoPlayer.view removeFromSuperview];
            });

        }
        
    }];

}

    
+(void)cropPhAsset:(PHAsset *)asset withRegion:(CGRect)rect onComplete:(void (^)(NSDictionary *))callback
    {
        if(asset.mediaType == PHAssetMediaTypeImage)//photo
        {
            
            PHImageManager *manager = [PHImageManager defaultManager];
            
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.synchronous = true;
            requestOptions.networkAccessAllowed = true;
            requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            
            [manager requestImageForAsset:asset
                               targetSize:PHImageManagerMaximumSize
                              contentMode:PHImageContentModeDefault
                                  options:requestOptions
                            resultHandler:^void(UIImage *image, NSDictionary *info) {
                                
                                [self cropImage:image withRegion:rect];
                                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"photo", @"type",
                                                      @"success", @"result",
                                                      [self cropImage:image withRegion:rect], @"image", nil];
                                callback((NSDictionary*) dict);
                                
                            }];

            
        }
        else if(asset.mediaType == PHAssetMediaTypeVideo)//video
        {
            [self cropVideo:asset withRegion:rect andCallback:^(NSDictionary* result){
                
                callback((NSDictionary*) result);
                
            }];
            
        }
        
}



- (CGRect) rangeRestrictForRect:(CGRect )unitRect
{
    //incase <0 or >1
    if(unitRect.origin.x < 0) unitRect.origin.x = 0;
    if(unitRect.origin.x > 1) unitRect.origin.x = 1;
    if(unitRect.origin.y < 0) unitRect.origin.y = 0;
    if(unitRect.origin.y > 1) unitRect.origin.y = 1;
    if(unitRect.size.height < 0) unitRect.size.height = 0;
    if(unitRect.size.height > 1) unitRect.size.height = 1;
    if(unitRect.size.width < 0) unitRect.size.width = 0;
    if(unitRect.size.width > 1) unitRect.size.width = 1;
    
    return unitRect;
}


#pragma mark -Video Process

+ (UIImageOrientation)getVideoOrientationFromAsset:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGAffineTransform txf       = [videoTrack preferredTransform];
    CGFloat videoAngleInDegree  = (atan2(txf.b, txf.a)) * 180 / M_PI;
    
    switch ((int)videoAngleInDegree) {
        case 0:
            return UIImageOrientationRight;
            break;
        case 90:
            return UIImageOrientationUp;
            break;
        case 180:
            return UIImageOrientationLeft;
            break;
        case -90:
            return UIImageOrientationDown;
            break;
        default:
            return UIImageOrientationUp;
            break;
    }

}


+ (void)cropVideo:(PHAsset *)asset2 withRegion:(CGRect)cropRect andCallback:(void(^)(NSDictionary *))callback
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    PHVideoRequestOptions *option = [PHVideoRequestOptions new];
    __block AVAsset *asset;

    [[PHImageManager defaultManager] requestAVAssetForVideo:asset2 options:option resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
        asset = avasset;
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"bekleme bitti");
    
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    CGFloat cropOffX = cropRect.origin.x;
    CGFloat cropOffY = cropRect.origin.y;
    int videoSize = cropRect.size.width; //MIN(clipVideoTrack.naturalSize.width,clipVideoTrack.naturalSize.height);
    
    if (videoSize % 16 != 0) {
        videoSize = videoSize - (videoSize%16);
    }
    
    videoComposition.renderSize = CGSizeMake(videoSize, videoSize);
    
    //create a video instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    UIImageOrientation videoOrientation = [self getVideoOrientationFromAsset:asset];
    
    CGAffineTransform t1 = CGAffineTransformIdentity;
    CGAffineTransform t2 = CGAffineTransformIdentity;
    
    switch (videoOrientation) {
        case UIImageOrientationUp:
            NSLog(@"UIImageOrientationUp");
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height - cropOffX, 0 - cropOffY );
            t2 = CGAffineTransformRotate(t1, M_PI_2 );
            break;
        case UIImageOrientationDown:
            NSLog(@"UIImageOrientationDown");
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, clipVideoTrack.naturalSize.width - cropOffY ); // not fixed width is the real height in upside down
            t2 = CGAffineTransformRotate(t1, - M_PI_2 );
            break;
        case UIImageOrientationRight:
            NSLog(@"UIImageOrientationRight");
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, 0 - cropOffY );
            t2 = CGAffineTransformRotate(t1, 0 );
            break;
        case UIImageOrientationLeft:
            NSLog(@"UIImageOrientationLeft");
            //cropOffX = clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height - cropOffX;
            //NSLog(@"cropOffX %f",cropOffX);
            
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.width - cropOffX, clipVideoTrack.naturalSize.height - cropOffY );
            t2 = CGAffineTransformRotate(t1, M_PI  );
            break;
        default:
            NSLog(@"no supported orientation has been found in this video");
            break;
    }
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    // Step 1
    // Create an outputURL to which the exported movie will be saved
    //NSString *outputURL = NSTemporaryDirectory();
    //outputURL = [outputURL stringByAppendingPathComponent:@"cropped.mov"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = [paths firstObject];
    outputURL = [outputURL stringByAppendingPathComponent:@"cropped.mov"];

    // Remove Existing File
    [self deleteTmpFile:outputURL];
    
    
    // Step 2
    // Create an export session with the composition and write the exported movie to the photo library
    AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    
    exportSession.videoComposition = videoComposition;
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            
            NSLog(@"crop success");
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"video", @"type", @"success", @"result", nil];
            callback((NSDictionary*)dict);
            
        }else{
            NSLog(@"Failed:%@",exportSession.error);

            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"video", @"type", @"failed", @"result", nil];
            callback((NSDictionary*)dict);
            
        }
        
    }];

    
}


+(void)deleteTmpFile:(NSString*)path{
    
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



#pragma mark -Image Process

+ (UIImage *)cropImage:(UIImage *)image withRegion:(CGRect)rect
{
    NSLog(@"%f %f %f %f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    
    UIImage * returnImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];

    //NSLog(@"%f %f",returnImage.size.width,returnImage.size.height);
    
    return returnImage;
}


static CGRect IGScaleRect(CGRect rect, CGFloat scale)
{
    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}

-(CGRect)_calcVisibleRectForCropArea{
    
    CGFloat sizeScale = self.imageView.image.size.width / self.imageView.frame.size.width;
    sizeScale *= self.zoomScale;
    CGRect visibleRect = [self convertRect:self.bounds toView:self.imageView];
    return visibleRect = IGScaleRect(visibleRect, sizeScale);
}

- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)img
{
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}



+ (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}



- (void)setPhAsset:(PHAsset *)asset2
{
    _phAsset = asset2;
    _mediaType = [asset2 mediaType];
    
    // clear the previous image
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    if(self.videoPlayer)
    {
        [self.videoPlayer stop];
        [self.videoPlayer.view removeFromSuperview];
    }

    
    //hide start mask and add observer
    self.videoStartMaskView.hidden = YES;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    PHImageManager *manager = [PHImageManager defaultManager];

    
    if(_mediaType == PHAssetMediaTypeImage)//photo
    {
        
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.synchronous = false;
        requestOptions.networkAccessAllowed = true;
        requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        [manager requestImageForAsset:asset2
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            
                            if (image.size.width <= 0 || image.size.height <= 0) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot use" message:@"This photo cannot be used" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alert show];
                                return;
                            }

                            // reset our zoomScale to 1.0 before doing any further calculations
                            self.zoomScale = 1.0;
                            
                            // make a new UIImageView for the new image
                            self.imageView = [[UIImageView alloc] initWithImage:image];
                            self.imageView.clipsToBounds = NO;
                            [self addSubview:self.imageView];
                            
                            
                            CGRect frame = self.imageView.frame;
                            if (image.size.height > image.size.width) {
                                frame.size.width = self.bounds.size.width;
                                frame.size.height = (self.bounds.size.width / image.size.width) * image.size.height;
                            } else {
                                frame.size.height = self.bounds.size.height;
                                frame.size.width = (self.bounds.size.height / image.size.height) * image.size.width;
                            }
                            self.imageView.frame = frame;
                            [self configureForImageSize:self.imageView.bounds.size];
                            _playState = 0;
                        }];

    }
    else
    {

        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        PHVideoRequestOptions *option = [PHVideoRequestOptions new];
        __block AVURLAsset *asset;

        [[PHImageManager defaultManager] requestAVAssetForVideo:asset2 options:option resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
            asset = (AVURLAsset *)avasset;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

                
        if (asset2.pixelWidth <= 0 || asset2.pixelHeight <= 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot use" message:@"This video cannot be used" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:asset.URL];
        self.videoPlayer.controlStyle = MPMovieControlStyleNone;
        self.videoPlayer.movieSourceType = MPMovieSourceTypeFile;
        self.videoPlayer.scalingMode = MPMovieScalingModeAspectFill;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        
        //CGSize assetSize = asset2.dimensions;
        CGSize size;
        if (asset2.pixelHeight > asset2.pixelWidth) {
            size.width = self.bounds.size.width;
            size.height = (self.bounds.size.width / asset2.pixelWidth) * asset2.pixelHeight;
            self.videoPlayerScale =  self.bounds.size.width / asset2.pixelWidth;

        } else {
            size.height = self.bounds.size.height;
            size.width = (self.bounds.size.height / asset2.pixelHeight) * asset2.pixelWidth;
            self.videoPlayerScale =  self.bounds.size.height / asset2.pixelHeight;

        }
        
        self.videoPlayer.view.frame = CGRectMake(0, 0, size.width, size.height);

        [self addSubview:self.videoPlayer.view];
        [self.videoPlayer play];
        [self configureForImageSize:self.videoPlayer.view.frame.size];
        
        _playState = 1;
    }
}


- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    
    //to center
    if (imageSize.width > imageSize.height) {
        self.contentOffset = CGPointMake(imageSize.width/4, 0);
    } else if (imageSize.width < imageSize.height) {
        self.contentOffset = CGPointMake(0, imageSize.height/4);
    }
    
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 2.0;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if((self.videoPlayer) && (_playState == 2))
    {
        _playState = 1;
        [self.videoPlayer play];
        self.videoStartMaskView.hidden = YES;

        
    }
}

#pragma mark - MPMoviePlayerController Notification
- (void) playerDidFinishedCallBack:(NSNotification *)notification
{
    _playState = 2;
    self.videoStartMaskView.hidden = NO;

}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


@end
