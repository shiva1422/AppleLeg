//
//  KSPlayerView.h
//  AVFoundatation
//
//  Created by shivaaz on 4/29/23.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIView.h"
#import "../Controllers/KSTransport.h"

NS_ASSUME_NONNULL_BEGIN

@class AVPlayer;

//@interface KSPlayerView : NSView

@interface KSPlayerView : UIView

-(id)initWithPlayer : (AVPlayer *)player;

@property(nonatomic,readonly) id<KSTransport> transport;

-(void)setPlayDelegate:(id<KSTransportDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
