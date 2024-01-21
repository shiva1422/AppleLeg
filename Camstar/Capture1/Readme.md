# CH - 6 Still Image Capture/simple Video(can only be tested on real device)

.This is simple Image capture patterned after apples built in cam app.Capture high-quality still images and Videos and write them to the IOS camera roll using the assets library framework.


KSPreviewView:
1.Implement a PreviewView to display realtime cam using AVCaptureVideoPreviewLayer.
2.Set AVCaptureSession  to the above layer to direct camera output to the layer.


KSCameraController:
.create KSCameraControllerDelagate that defines methods for error handling used t
.create and implement KSCameraController(IPlayerController) interface to control capture.
.methods for configuring and controlling capture session.
.methods to switch betweern cameras and test various capablitlies,methos to tap-to-focus and tap-to-expose
.Methods to capture still images andd Videos.
 
 *create session
 *create Audio and Video device and device inputs;
 *add inputs to session
 *create AVCaptureOutput(stillImage) and movieOutput(fileoutput) and add to session;




//methods to convert from screencoords to camera device coords
1.catpureDevicePointOfInterestForPoint
2.pointForCaptureDevicePointOfIntterest.

***Configuring the AVCaptureDevice
.AVCaptureDevice gives great deal of control over camera,specifically to adujust and lock cameras's focus,exposure and white balance, led used for cameras flash and torch
.its essential to check if the configurations are supported by the device.for example front facing camer  doesn't support focus operations because its almost at a arms lenght.


***Adjusting Focus and TorchModes
Focus:AVCaptureFocusModeAutoFocus
exposure : default mode AVCaptureExposureModeContinuousAutoExposure.

****Adjusting Flash and Torch Modes
AVCaptureDevice enables to modify cameras flash and torch modes;
.AVCapture(Torch|Flash)ModeOn/off : Alwayson/off, or Auto


****Capture Still Images:
*AVCaptureStillImageOutput class defines the captureStillImageAsynchronouslyFromConnection:completionHandler: to performa actual captureue;

*connections are formed automatically when input and output are added to sessions.
.Ex : AVCaptureConnection *connection = //active video Capture Connection
id completionHandleer = ^(CMSampleBufferRef buffer,NSError *error)
{
    //handle Image Capture;
}
[imageOutput captureStillImageAsynchronoulsyFromConnection:connection completionHandler:completionHandler];

*caputre Image convert to UIImage from CMSampleBufferRef's NSData.



//write to the Assets Library:
*Assets Library framework provides programmatic access to the user's photo and video library managed by IOS photos app.
*ALAssetsLibrary provides a number of "Write" methods to write to photor or videos to the users's library.
**ALAssetsLibrary deprecated use photosFramework.
*access need to be authorized by the user first.
 ex. ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
 if(status = ALAuthorizationStatusDenied)
 {
   //show promot cannot proced
}
else
{
    //perform authorized access to the library.
}



*****Capturing Videos:

*AVCaptureSession has added output called AVCaptureMovieFileOutput which is inherited from AVCaptureFileOutput which provides convinent way of quicktime movies disk with ability to record for a max duraion or until particular file size is reached.

*QuickTimeMovie.

During distribution : movie header metadata is placed at the beginning of the file .This enables video player to quickly read header to determine contents of file and structure and location of various samples it cotains.

During recording : 

 *the header can't be created until all samples have been captured.After recording is stopped the header will be created and appended at the end of the file.This can lose content or create unreadable file when there is any interruption like a crash or phone calls.
   
  *The AVCaptureMovieFileOutput provides capbility to capture quciktime movies in fragments .When recording begins minimal header will be written at the beginning of file and as recording proceeds ,a fragment will be written at some periodic intervals to build fully formed header.By default fragments will be written every 10 seconds and can be  changed by caputure outputs movieFragmentInterval propery.


*Adopt AVCaptureFileOutputRecordingDelegate and implement caputreOutput method in CameraCOntroller to get finalized file and write it to camera roll.

*finally generate thumbnail from AVAsset and AVAssetImageGenerator and post thumbnail notification safely.

