//
//  KSCustomPlayerView.h
//  AVPlayerIOS
//
//  Created by shivaaz on 6/3/23.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import "../Controllers/KSTransport.h"
#import "../MetalLib/UI/KSMetalView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSMetalPlayerView : KSMetalView

-(id)initWithPlayer : (AVPlayer *)player;

@property(nonatomic,readonly) id<KSTransport> transport;

-(void)setPlayDelegate:(id<KSTransportDelegate>)delegate;

-(void)setAVPlayerVideoOutSource:(AVPlayerItemVideoOutput *)videoSource;

@end

NS_ASSUME_NONNULL_END
