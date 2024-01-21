//
//  KSPlayerController.m
//  AVFoundatation
//
//  Created by shivaaz on 4/30/23.
//

#import "KSPlayerController.h"
#import "KSTransport.h"
#import "AVFoundation/AVFoundation.h"
#import "../LViews/KSPlayerView.h"
#import "../LViews/KSMetalPlayerView.h"

#import "../LViews/KSAVPlayerItemVideoOutput.h"

// status property of AVPlayerItem
#define STATUS_KEYPATH @"status"

//for timed observation of AVPlayer
#define REFRESH_INTERVAL 0.5f

//keyValue observation context
static const NSString *playerItemStatusContext;


@interface KSPlayerController ()  <KSTransportDelegate>

@property(strong,nonatomic) AVAsset *asset;
@property(strong,nonatomic) AVPlayerItem *playerItem;
@property(strong,nonatomic) AVPlayer *player;
//@property(strong,nonatomic) KSPlayerView *playerView;
@property(strong,nonatomic) KSMetalPlayerView *playerView;

@property(strong,nonatomic) KSAVPlayerItemVideoOutput *videoCustomTarget;


@property(weak,nonatomic) id<KSTransport> transport;

@property(strong ,nonatomic) id timeObserver;
@property(strong ,nonatomic) id itemEndObserver;
@property(assign ,nonatomic) float lastPlaybackRate;

@end

@implementation KSPlayerController

-(id)initWithURL:(NSURL *)assetURL
{
    self = [super init];
    if(self)
    {
        _asset = [AVAsset assetWithURL:assetURL];
        [self prepare];
    }
    
    return self;
}

-(void)dealloc
{
    if(self.itemEndObserver)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self.itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        self.itemEndObserver = nil;
    }
}
-(void)prepare
{
    NSArray *keys = @[@"tracks",@"duration",@"commonMetadata"];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
        
    
    [self.playerItem addObserver:self forKeyPath:STATUS_KEYPATH options:0 context:&playerItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    
    
    self.playerView = [[KSMetalPlayerView alloc] initWithPlayer:self.player];
    
    [self.playerView setPlayDelegate:self];

    self.transport = self.playerView.transport;
    
    
    
}

//obser key value from above
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if(context == &playerItemStatusContext)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];
            if(self.playerItem.status == AVPlayerItemStatusReadyToPlay)
            {
                //add time observers//TODO
                //AVPlayer provides towo kinds of observeser periodic time observation(eg.updating playback status)
                //boundary time observation .at regular intervals like 25% of play etc.to achiever specific functionlity at those points.
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                
                CMTime duration = self.playerItem.duration;
                [self.transport setTotalDurationSecs:CMTimeGetSeconds(duration)];
                //sync the time display
                [self.transport setCurrentTime:CMTimeGetSeconds(kCMTimeZero) duration:CMTimeGetSeconds(duration)];
                
                
                
               
                NSArray *titleMetadata = [AVMetadataItem metadataItemsFromArray:self.asset.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
                
                NSString *title = @"not found";
                if(titleMetadata.count > 0)
                {
                    AVMetadataItem *item = titleMetadata[0];
                    title = item.stringValue;
                    NSLog(@"metadata : %@ - %@",item.key,item.value);
                }
                
                [self.transport setTitle:title];
                
                
                NSDictionary* pixelAttributes =
                    @{
                         (NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB),
                         (NSString*)kCVPixelBufferBytesPerRowAlignmentKey: @1,
                         (NSString*)kCVPixelBufferMetalCompatibilityKey: @YES
                    };
                
                self.videoCustomTarget = [[KSAVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelAttributes];
                
                self.videoCustomTarget.suppressesPlayerRendering = YES;//Custom rendering  in KSCustomPlayerView of video output.
                
               // [self.videoCustomTarget setDelegate:self queue:myDispatchQueue];

                
                assert(self->_videoCustomTarget);
                [self.playerView setAVPlayerVideoOutSource:self.videoCustomTarget];
                
                [self.playerItem addOutput:self.videoCustomTarget];
                
                [self.player play];
            }
        });
    }
    else
    {
       //so alert on ui
        NSLog(@"error - not player status");
    }
}
-(void)addPlayerItemTimeObserver{
    
    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    //callback block for time observer;
    __weak KSPlayerController *weakSelf = self;
    
    void(^callback)(CMTime time) = ^(CMTime time){
        
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(time);
        [weakSelf.transport setCurrentTime:currentTime duration:duration];
        
    };
    
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:callback];
    
}

-(void)addItemEndObserverForPlayerItem{
    
    //eos status observer
    
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    __weak KSPlayerController *weakSelf = self;
    void(^callback)(NSNotification *note) = ^(NSNotification *notification){
        
        
        //[weakSelf.player seekToTime:kCMTimeZero completionHander:^(BOOL finished)
        [weakSelf.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.transport playbackComplete];
        }];
         
    };
    
    self.itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:name object:self.playerItem queue:queue usingBlock:callback];
    
    
}


//Implement Transport Delgate callbacks

-(void)play
{
    [self.player play];
}

-(void)pause
{
    self.lastPlaybackRate =  self.player.rate;//TODO
    [self.player pause];
}

-(void)stop{
    
    [self.player setRate:0.0f];//mean pause
    [self.transport playbackComplete];
    
}

-(void)onJumpToTime:(NSTimeInterval)time{
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)onStartScrubbing {
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];

}

- (void)onScrubToTime:(NSTimeInterval)time {
    [self.playerItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(time,NSEC_PER_SEC )];
}


- (void)onEndScrubbing {
    
    [self addPlayerItemTimeObserver];
    if(self.lastPlaybackRate > 0.0f)//TODO this shoulb be set right.
    {
        [self.player play];
    }
    
}


-(UIView *)getVideoTarget
{
    return self.playerView;
}

@end
