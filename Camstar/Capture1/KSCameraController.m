//
//  KSCameraController.m
//  Camstar
//
//  Created by shivaaz on 7/8/23.
//

#import "KSCameraController.h"
#include "UIKit/UIKit.h"
#include "AssetsLibrary/ALAssetsLibrary.h"
#include "FileProvider/NSFileProviderManager.h"
@interface KSCameraController() <AVCaptureFileOutputRecordingDelegate>

@property(strong , nonatomic) dispatch_queue_t videoQ;
@property(strong,nonatomic) AVCaptureSession *captureSession;
@property(weak, nonatomic) AVCaptureDeviceInput *activeVideoInput;



@property(strong, nonatomic) AVCaptureStillImageOutput *imageOutput;//TODO deprecated use AVCapturePhotoOutput
@property(strong ,nonatomic) AVCaptureMovieFileOutput *movieOutput;
@property(strong ,nonatomic) NSURL *outputURL;

@end

@implementation KSCameraController

-(BOOL)setupSession:(NSError **)error
{
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //set up default camera device;
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    
    if(videoInput)
    {
        if([self.captureSession canAddInput:videoInput])
        {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    }
    else
    {
        return NO;
    }
    
    //setup default Mic
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if(audioInput)
    {
        if([self.captureSession canAddInput:audioInput])
        {
            [self.captureSession addInput:audioInput];
        }
        
    }
    else
    {
        return NO;
    }
    
    //setup still imageoutput/this various for different cases like still image,videooutpu,lowlevel access to samples
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecTypeJPEG};
    
    if([self.captureSession canAddOutput:self.imageOutput])
    {
        if([self.captureSession canAddOutput:self.imageOutput])
        {
            [self.captureSession addOutput:self.imageOutput];
        }
    }
    
    
    //setup movie file output;
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if([self.captureSession canAddOutput:self.movieOutput])
    {
        [self.captureSession addOutput:self.movieOutput];
    }
    
    self.videoQ = dispatch_queue_create("com.tapharmonic.VideoQueue", NULL);
    
    return YES;
    
}

-(void)startSession
{
    if(![self.captureSession isRunning])
    {
        dispatch_async(self.videoQ, ^{
            [self.captureSession startRunning];
        });
    }
}

-(void)stopSession
{
    if([self.captureSession isRunning])
    {
        dispatch_async(self.videoQ, ^{
            [self.captureSession stopRunning];
        });
    }
}


//switching cameras

-(AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *device in devices)
    {
        if(device.position == position)
        {
            return device;
        }
    }
    
    return nil;
}

-(AVCaptureDevice *)activeCamera
{
    return self.activeVideoInput.device;
}

-(AVCaptureDevice *)inactiveCamera
{
    AVCaptureDevice *device = nil;
    if(self.cameraCnt > 1)
    {
        if([self activeCamera].position == AVCaptureDevicePositionBack)
        {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else
        {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    
    return device;
}

-(BOOL)canSwitchCameras
{
    return  self.cameraCnt > 1;
}

-(NSUInteger)cameraCount
{
    //TODO deprecated.
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

-(BOOL)switchCameras
{
    if(![self canSwitchCameras])
    {
        return NO;
    }
    
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if(videoInput)
    {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        
        if([self.captureSession canAddInput:videoInput])
        {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
        else{
            [self.captureSession addInput:self.activeVideoInput];
        }
        
        [self.captureSession commitConfiguration];
    }
    else
    {
        [self.delegate onDeviceConfigFailed:error];
        return  NO;
    }
    
    return YES;
}


//Adjusting Focus and Exposure

-(BOOL)cameraSupportsTapToFocus
{
    return  [[self activeCamera] isFocusPointOfInterestSupported];
}

-(void)focusAtPoint:(CGPoint)point//this point is converted from screen COords to Camera device Coords in KSPreviewView
{
    AVCaptureDevice *device = [self activeCamera];
    if(device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        NSError *error;
        if([device lockForConfiguration:&error])
        {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        else
        {
            [self.delegate onDeviceConfigFailed:error];
        }
    }
}


-(BOOL)cameraSupportsTapToExpose
{
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static const NSString *KSACameraAdjustingExposureContext;

-(void) exposeAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    
    if(device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode])
    {
        NSError *error;
        if([device lockForConfiguration:&error])
        {
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            
            if([device isExposureModeSupported:AVCaptureExposureModeLocked])
            {
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&KSACameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        }
        else
        {
            [ self.delegate onDeviceConfigFailed:error];
        }
    }
    //****CHECK below observeValueForKeyPath
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if(context == &KSACameraAdjustingExposureContext)
    {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        
        if(!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked])
        {
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&KSACameraAdjustingExposureContext];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            if([device lockForConfiguration:&error])
            {
                device.exposureMode = AVCaptureExposureModeLocked;
                [device unlockForConfiguration];
            }
            else
            {
                [self.delegate onDeviceConfigFailed:error];
            }
            
        });
        
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

-(void)resetFocusAndExposureModes
{
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    
    AVCaptureExposureMode exposureMode= AVCaptureExposureModeContinuousAutoExposure;
    
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    
    CGPoint centrePoint = CGPointMake(0.5f, 0.5f);
    
    NSError *error;
    if([device lockForConfiguration:&error])
    {
        if(canResetFocus)
        {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centrePoint;
        }
        
        if(canResetExposure)
        {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centrePoint;
        }
        
        [device unlockForConfiguration];

    }
    else
    {
        [self.delegate onDeviceConfigFailed:error];
    }
    
   
}


//Adjusting the flash and TorchModes
-(BOOL)cameraHasFlash
{
    return [[self activeCamera] hasFlash];
}

-(AVCaptureFlashMode)flashMode
{
    return [[self activeCamera] flashMode];
}

-(void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice *device = [self activeCamera];
    
    if([device isFlashModeSupported:flashMode])
    {
        NSError *error;
        if([device lockForConfiguration:&error])
        {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
        else
        {
            [self.delegate onDeviceConfigFailed:error];
        }
    }
}


-(BOOL)cameraHasTorch
{
    return [[self activeCamera] hasTorch];
}

-(AVCaptureTorchMode)torchMode{
    return [[self activeCamera] torchMode];
}

-(void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = [self activeCamera];
    if([device isTorchModeSupported:torchMode])
    {
        NSError *error;
        if([device lockForConfiguration:&error])
        {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        else
        {
            [self.delegate onDeviceConfigFailed:error];
        }
    }
}



//Capturing

-(void)captureStillImage
{
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if(connection.isVideoOrientationSupported)
    {
        connection.videoOrientation = [self currentVideoOrientation];//below
    }
    
    id handler = ^(CMSampleBufferRef sampleBuffer,NSError *error)
    {
        if(sampleBuffer != NULL)
        {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [self writeImageToAssetsLibrary:image];//below
           
        }
        else
        {
            NSLog(@"Null SampleBuffer :%@",[error localizedDescription]);
        }

    };
    
    //capture still image
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:handler];
    
}

-(AVCaptureVideoOrientation)currentVideoOrientation
{
    AVCaptureVideoOrientation orientation;
    
    switch([UIDevice currentDevice].orientation)
    {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            assert(false);//implement othere 198;
    }
    return orientation;
}

-(void)writeImageToAssetsLibrary:(UIImage *)image
{
    //TODO deprecated
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if(!error)
        {
            [self postThumbnailNotification:image];
        }
        else
        {
            id message = [error localizedDescription];
            NSLog(@"Error: %@",message);
        }
    }];
}

-(void)postThumbnailNotification:(UIImage *)image
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:onThumbnailCreatedNotification object:image];
}

//Movie output config,start/stop recording
-(BOOL)isRecording
{
    return self.movieOutput.isRecording;
}

-(void)startRecording
{
    if(![self isRecording])
    {
        AVCaptureConnection *videoConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if([videoConnection isVideoOrientationSupported])
        {
            videoConnection.videoOrientation = [self currentVideoOrientation];
        }
        
        if([videoConnection isVideoStabilizationSupported])
        {
            videoConnection.enablesVideoStabilizationWhenAvailable = YES;
        }
    }
    
    AVCaptureDevice *device = [self activeCamera];
    
    if(device.isSmoothAutoFocusSupported)
    {
        NSError *error;
        if([device lockForConfiguration:&error])
        {
            device.smoothAutoFocusEnabled = YES;
            [device unlockForConfiguration];
        }
        else
        {
            [self.delegate onDeviceConfigFailed:error];
        }
    }
    
    self.outputURL = [self uniqueURL];
    [self.movieOutput startRecordingToOutputFileURL:self.outputURL recordingDelegate:self];
}

-(NSURL *)uniqueURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dir = [fileManager temporaryDirectory];//TODO atually apth 204
    
    if(dir)
    {
        NSString *filePath = [dir stringByAppendingPathComponent:@"my_movie.mov"];
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

-(void)stopRecording
{
  if([self isRecording])
  {
      [self.movieOutput stopRecording];
  }
}


//implemnt AVCaptureFileOutputRecordingDelegate for Video method to write file to cam roll

-(void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error
{
    if(error)
    {
        [self.delegate onMediaCaptureFailed:error];
    }
    else
    {
        [self writeVideoToAssetsLibrary:[self.outputURL copy]];
    }
    
    self.outputURL = nil;
}

-(void)writeVideoToAssetsLibrary:(NSURL *)videoURL
{
    ALAssetsLibrary *libarary = [[ALAssetsLibrary alloc] init];
    if([libarary videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL])
    {
        ALAssetsLibraryWriteVideoCompletionBlock completionBlock;
        completionBlock = ^(NSURL *assetURL,NSError *error)
        {
            if(error)
            {
                [self.delegate onAssetLibraryWriteFailed:error];
            }
            else
            {
                [self generateThumbnailForVideoAtURL:videoURL];
            }
        };
        
        [libarary writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:completionBlock]
    }
}

//generate thumbnail after write to library

-(void)generateThumbnailForVideoAtURL:(NSURL *)videoURL
{
    dispatch_async(self.videoQ, ^{
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        imageGenerator.maximumSize = CGSizeMake(100.0f,0.0f);
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
        
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postThumbnailNotification:image];
        })
    })
}
@end
