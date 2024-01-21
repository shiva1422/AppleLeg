//
//  KSTransportDelegate.h
//  AVFoundatation
//
//  Created by shivaaz on 4/30/23.
//

#import <Foundation/Foundation.h>

@protocol KSTransportDelegate <NSObject>

-(void)play;
-(void)pause;
-(void)stop;
-(void)onStartScrubbing;
-(void)onScrubToTime:(NSTimeInterval)time ;
-(void)onEndScrubbing;
-(void)onJumpToTime:(NSTimeInterval)time;

@end


@protocol KSTransport <NSObject>

@property(weak,nonatomic) id <KSTransportDelegate> delegate;

-(void)setTitle:(NSString *)title;
-(void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
-(void)setScrubbingTime:(NSTimeInterval)time;
-(void)playbackComplete;
-(void)setTotalDurationSecs:(double) duration;

@end


