# 1 AVFoundation Intro
AVFoundation is apples advanced objective-C framework for working with time-based media on osx and ios.


            IOS                                               MAC
            AVKit                                             AVKit
            UIKit                                            Appkit
                                                
                AVFoundation(part audio-only classes)
Core Audio      Core Video          Core Media          Core Animation


Audio only Classes:

AVAudioPlayer and AVAudioRecorder.


Compressions:

H.264 along with other forms of MPEG compression ,reduces the size of video content in two ways.

1.Spacially:compresses individual frames referred to as intra frame(I-Frames) compression.(like jpeg)
2.Temporal: compresses reduncies across groups of video frames.Interframe compression.
with interfame compression frames are grouped together into a group of pictures(GOP).within this GOP certian temporal reduncies exist that can be eliminated .If you think about a typical scene in video,there are certain elements in motions,such as a car driving by or a person walking down the street,but the background environment is often fixed.The fixed background represents a temporal redundancy that could be eliminated through compression.

There are three types of frames that are store within a GOP :

1.I-Frames : These are the standalone or key frames and conain all the data needed to ceate the complete image.Every GOP has exactly one I-frame (largest in size fastest to compress).
2.P-Frames: predicted frame , are encoded from a predicted picture based on the closese I-Frame of P-Frame.These are often referred to as reference frames as their neighboring P-frames and B-frames can refer to them.

3.B-Frames : bidirectional frame are encoded based on the frame inpormation that compes before and after them.They require little space,but take longer to decompress because thay are reliant on their surrounding frames.


H.264 additionally supports encoding profiles,which determinne the algorithms employed during the encoding proces.

There are three top-level profiles defined:

1.Baseline : common for mobile devices.least efficient ,larger file size als least computationlly intesive as it doesn't contain B-Frames.

2.Main : more computaionally intensive than baseline,(algorihtms) but high compression rations.

3.High:high profile will result in highest quality compression being used.but mose intensive of three(encoding techs and algos).

for editing puposes apple h.264 also provides I-frame obly variant.

//Apples ProsRes Codec.

In additional to H.264 and Apple Pros res codecc AV Foundations support MPEG1-4 ,h.263 ad DV.


COntainer formats like .mov,.m4v,.mpg and .m4a,.mp4 can be thoght of a directory containing one or more types of media along with meta data.

*NSSpeechSYnthesizer:



******2.Audio playback and Recording.

*Audio Session(IOS) is an intermediary between app and OS provides a simple and elegant way of communicating to the OS and how app should interact with ios audio environment.

*seven categories of Audio session used for games ,players ,record etc purposes.

*create shared instance of AVAudioSession specifying the category and make it active
*AVAudioPlayer,AVAudioRecorder


********3.Working with Assets and Metadata.
AVAsset is central to AVFoundaations design and is an abstract immutalble class providing a composite representation of a media resource,modelling the static attributes of the meadia as a whole such as its title,duration,metadata.abstracts away underlying media format(mp4,mp3 ,quicktime etc) and provides uniform way of working with media withour concerniing about underlying codec and container.

*AVAssets is not the media itself ,but acts as container for timed media.
**AVAsset contains array of NSArray AVAssetTrack(audio or video stream,tet,subtitles,closed captions etc.)

***Creating an asset using url
NSURL *assetUrl = //url
AVAsset *asset = [AVAsset assetWithURL:assetURL];//is an abstract class ,so cant be directly initiated
actually above is creating an instance of one of its subclasess called AVURLAsset.

//also provides ability to fine tune how asset is created by passing it a dictionary of options.ex.for editing purposes more preecise duraition and timing can be obtained as follows.

NSURL *assetURL = //URL
NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey: @YES};
AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:assetURL options:options];

**Different Location from wher Asset can be loaded:62
IOS:AssetsLibrary framework ,typically photos captures into photos library
IPODS Library:
Mac iTunes Library:

AVAsset has asynchronous loading for effeciency.i.e info is not creted until requested although not ideal for all cases as sometime header might need to be parsed to get a single param like duration.

*AVAsset and AVAssetTrack both adopt a protocol called AVAsynchronoysKeyVallueLoading.This Protocol provides a means of quering properties asynchronously by providing the following methods:

- (AVKeyValueStatus) statusOfValueForKey: (NSString *)key error : (NSError **)outError
-(void) loadValuesAsynchronouslyForKeys: (NSArray *)keys completionHandler:(void (^)(void)handler


****meta data formats

most common media formats apples quicktime(mov) , mp4 video(mp4 and m4v),mp4 audio(m4a),mp-3 audio(mp3).

1.QuickTimeFile(mov) : composed of data structures called atoms.
 .atom : contains data describing an aspect of the media or other atoms(not both but may be)
 genrally contains 3 top-level atoms ftyp(file type and compatible brands),mdat(actual audio and video media),and all-important moov atom (moo-vee) which fully describes the relevant details of the media including presentable meta data.
2.mp4 is a direct descendant of quick time so has similar format.

3.mp3 is sigificantly differ it doesn't use a container format instead it ai encoded audio data with an optional structured block of metadatatypically prepended to the beginning of the file.mp3 use a format called ID3V2 to store descriptive information abut audio content including data such as artist ,album and genre.

*AVTrack and AVAssetTrack privide metadata.interface for reading an items metadata is provided by a class called AVMetadataItem which provides object-oriented interface to access the metadata storeed in quicktime and mpeg-4 atoms and ID3 frames.

*Metadata can be in two spaces
    a.common metadata for all formats:
    b.format specific metadata (accesed using metadataForFormat)

*MetadataManagerApp 76;

*convertig artwork followed by comments ,track,disc and genre metadata:86


*Saving metadata : AVAssetExportSession.98



*4 - Playing Video:

*AVPlayer is like IPlayerController.
*AVPlayerLayer : (rendering surface to video output).To directect a video output to destination in UI.built on top of core animation(built using opengl).
  -extends Core Animations CALayer class and is used by the framework to render video content to the scree.
  -AVLayerVideoGravityResizeAspect(Fill) : scale video withing layers bounds
*AVQueuePlayer : to Play sequence of Assets.is a subclass of AVPlayerLayer.
*AVPlayerItem:
  -AVAsset only has static aspects of media ,doesn't provide an dynamic counterparts like play,seek for which we need to construct AVPlayerItem and AVPlayerItemTrack classes.
 -provids methods like seekToTime:,presentationSize,currentTime.

*Tracks forund in AVPlayerItem directly correspond to AVAssetTrack found in AVAsset

        AVAsset          <--------       AVAssetTrack
           ^
           |
      AVPlayerItem       <---------   AVPlayerItemTrack
           ^
           |        
          
        AVPlayer         <---------    AVPlayerLayer
        
        
*AVPlayerItemStatus  should be readyTOPlayer before starting playback;

*AVPlayer also providies two time based observations for a finer contro:
 a.periodic time observation
 b.boundary time observation.


*124 creating visual scrubber seekFrames then showing subtitles and then airplay
