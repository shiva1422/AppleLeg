#  CH 7 : Using Advanced Capture Features:



****Video Zooming

*videoScaleAndCropFactor property on AVCaptureConnection level.
*AVCaptureDevice provides property called videoZoomFactor that enables to control zoom level on capture device.


***Face detectiton.

*AVCaptureMetadataOutput 

****Machine Readable Code detection



****High Frame Rate Capture:
AVCaptureDeviceFormat.videoSupportedFrajmeRateRanges.
AVFrameRateChange.
quality of service QOS.



****Processing Video:(AVCaptureVideoDataOutput)

*previously used AVCaptureMovieFileOutput to capture quciktime movie.doesn't provide a access to video data.
*Instead to get Access to video data use caputureOutput AVCaptureVideoDataOutput.
*AVCaptureVideoDataOutput outputs objects containing videodata via its AVCaptureVideoDataOutputSampleBufferDelegate protocol.

**AVCaptureVideoDataOutputSampleBufferDelegate has following methods:
a.captureOutput:ddidOutputSampleBuffer:fromConnection;(called Whenever new frame is written)
b.catpureOutput:didDropSampleBuffer:fromConnection:called whenever a late(due to above delay in above callback processing ) video frame is dropped.

***understanding CMSampleBuffer.

*wrapper around underlying sample data shuttled through media pipleline in CoreMedia Framework.
*provides format and timing information and anyother metadata interprete and process the data.



***************CH 8 Reading and Writing Media" - Low level reading and writing .

*AVAssetReader & AVAssetWriter - world of possiblities.figure 260.

*AVAssetReader:
    .used to read media samples from an instance of AVAsset.
    .Configure with one or more instance of AVAssetReaderOutput,which provides acces to audio samples and video frames using it copyNextSampleBuffer method.
     .AVAssetReader abstract class ,provides three concrete subclasses(AVAssetReaderTrackOutput,AVAssetReaderAudioMixOutput,AVAssetReaderVideoCompositionOutput) that enable to read decoded media samples from a speciic AVAssetTrack and also mixed output from multiples audio tracls or composited output from multiple video tracks.
    
*AVAssetWirter:
 .to encode and write media to a container files such as MPEG-4 or QuickTime file ,configured with one or more AVAssetWriterInput objects which append CMSampleBuffer objects containing the media samples to be written to te ocontainer.
 .


