//
//  KSPlayer.m
//  AVFoundatation
//
//  Created by shivaaz on 4/29/23.
//

#import "KSPlayer.h"

static const NSString* playerItemStatusContext;
@interface KSPlayer()

@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *videoTarget;


@end

@implementation KSPlayer

-(instancetype)initWithURL:(NSURL *)assetURL
{
    self = [super init];
    
    AVAsset *asset = [AVAsset assetWithURL:assetURL];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    //observes "status" proepry
    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:&playerItemStatusContext];
    
    //todo add as member
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    //to direct video output;
    self.videoTarget = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    //if insider ViewController.
   // [self.view.layer addSublayer:playerLayer];
    
    return self;
}

-(NSInteger)preparePlayer
{
    return 0;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context
{
    if(context == &playerItemStatusContext)
    {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if(playerItem.status == AVPlayerItemStatusReadyToPlay)
        {
            //can play nowc.
        }
    }
    
    
}

@end
