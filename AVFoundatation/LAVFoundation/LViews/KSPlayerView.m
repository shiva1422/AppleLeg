//
//  KSPlayerView.m
//  AVFoundatation
//
//  Created by shivaaz on 4/29/23.
//

#import "KSPlayerView.h"
#import "AVFoundation/AVFoundation.h"

@interface KSPlayerView ()

//@property(strong , nonatomic) KSOverlayView *overlayView;//for UserInterface;

@end

@implementation KSPlayerView

+(Class)layerClass
{
    return [AVPlayerLayer class];
}

-(id)initWithPlayer : (AVPlayer *)player
{
    
    self = [super initWithFrame:CGRectZero];
    
    if(self)
    {
        // UIView
        self.backgoundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        //FOR NSView
        //self.layer.backgroundColor = (__bridge CGColorRef _Nullable)(NSColor.blackColor);
        //self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        
        [(AVPlayerLayer *) [self layer] setPlayer:player];
        //TODO *******112 addsubview//OverlayView;
    }

    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews]
    [self.overlayView.frame = self.bounds];
}

-(id <KSTransport>)transport
{
    //TODO
    return self//.overlayView;
}


@end
