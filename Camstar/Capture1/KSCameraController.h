//
//  KSCameraController.h
//  Camstar
//
//  Created by shivaaz on 7/8/23.
//


#import "AVFoundation/AVFoundation.h"

extern NSString *const onThumbnailCreatedNotification;

@protocol KSCameraControllerDelegate <NSObject>

-(void)onDeviceConfigFailed:(NSError *)error;
-(void)onMediaCaptureFailed:(NSError *)error;
-(void)onAssetLibraryWriteFailed:(NSError *)error;
@end

@interface KSCameraController : NSObject

@property(weak , nonatomic) id<KSCameraControllerDelegate> delegate;
@property(nonatomic,strong,readonly)AVCaptureSession *captureSession;

//config session

-(BOOL)setupSession:(NSError **)error;
-(void)startSession;
-(void)stopSession;


//camera device support
-(BOOL)switchCameras;
-(BOOL)canSwitchCameras;

@property(nonatomic,readonly) NSUInteger cameraCnt;
@property(nonatomic,readonly) BOOL cameraHasTorch;
@property(nonatomic,readonly) BOOL cameraHasFlash;
@property(nonatomic,readonly) BOOL cameraSupportsTapToFocus;
@property(nonatomic,readonly) BOOL cameraSupportsTapToExpose;
@property(nonatomic)    AVCaptureTorchMode torchMode;
@property(nonatomic)    AVCaptureFlashMode flashMode;


//TapToXmethods

-(void)focusAtPoint:(CGPoint)point;
-(void)exposeAtPoint:(CGPoint)point;
-(void)resetFocusAndExposureModes;


//MediaCapture Methods;

-(void)captureStillImage;;
-(void)startRecording;
-(void)stopRecording;
-(BOOL)isRecording;

@end

