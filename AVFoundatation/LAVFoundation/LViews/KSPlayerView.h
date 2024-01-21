//
//  KSPlayerView.h
//  AVFoundatation
//
//  Created by shivaaz on 4/29/23.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class AVPlayer;

//@interface KSPlayerView : NSView

@interface KSPlayerView : UIView

-(id)initWithPlayer : (AVPlayer *)player;

//TODO transport

@end

NS_ASSUME_NONNULL_END
