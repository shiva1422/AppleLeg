#  5 . AV Kit

AVKit simplifies the process of building AVFoundation based video players that match look and feel of the default operating system players.

.IOS mediaplayer framework has MPMoviePlayerController and MPMoviePlayerViewController.

.now for ios only has AVPlayerViewController with controllers.Mac has AVPlayerView,
.then titles movie modernization etc.


6.Media Capture.

There are some differnce in mac and osx plats.

.AVCaptureScreenInput class used for screen ercording ,whereas ios doesn not due to sand boxing.

p-170 classes involved in capture app.

*AVCaptureSession : connects input and ouput devices and flow of data from cam/mic to output destinations and routing can be configured on the fly.can be configured with a 'session preset' which controls the format and quality of captured data.

*AVCaptureDevice:
provides an interface to a physical device such as camera or a mic.(can also represent non device integrated like external cam,camcoder).provides cconsiderabele control over physical harware like focus,exposure,white balance and flash.

.provides many class methods to get systems capture devices.to get default videoDevice
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

*AVCaptureDeviceInput(like a virtual path cable connecting AVCaptureSession and AVCaptureDevice:

.AVCaptureDevice needs to be added as input to AVCaptureSession before doing anything but can't do directly and must be wrapped in instance of AVCaptureDeviceInput.

        .NSError *error;
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWIthDevice:videoDevice error:&error];
        

*Capture Outputs:

AVFoundation has a number of classes extending AVCaptureOutput which is abstract base class representing destination from AVCaptureSession

.higher levelv classes extending AVCaptureOutput - AVCaptureStillImageOutput(deprecated use AVCapturePhotoOutpu),AVCaptureMovieFileOutput.
.Lower level classes AVCaptureVideoDataOutput and AVCaptureAudioDataOutput which provide direct access to digital samples.

*AVCaptureConnection: connection between session,input,output,devices.can be used to enable/disable audio/video.




*CapturePreview:

AVCaptureVideoPreviewLayer from CALayer to provide realtime preivew of capture video data similar to AVPlayerLayer.





  Setting up a Simple Camera App :
  
  1.Create a Capture Session
  AVCaptureSession *session = [[AVCaptureSession alloc] init];
  
  2.Get Reference to default camera(AVCaptureDevice).
  AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  3.Create a device input with(AVCaptureDeviceInput) input for the camera.
  AVCaptureDeviceInput *camInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&erro];
  
  4.connect the input to the session.
  if([session canAddInput:camInput])
  {
    [session addInput:camInput];  
}

  5.Create an AVCaptureOutpu to caputre still images.
  AVCaptureStillImageOutput *imageOuput = [[AVCaptureStillImageOutput alloc] init];
  
  
  6.Add output to session
  if([session canAddOuput:imageOutpu])
  {
    [session addOutput:imageOutput];
    }

   7.start the session and begin the flow of data.
    [session start running];

//The above setups up simple infrasturcture required for captureing still images from the default cam.

*AVCaptureDevicePosition enum for front or back cameras.

*switching cameras on the fly
    .caputuresession.beginCofigurations
    .removeInput - before camInput
    .addInput -new CamInput
    .commitConfiguration.
