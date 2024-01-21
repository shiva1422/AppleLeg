//
//  KSPlayerView.m
//  AVFoundatation
//
//  Created by shivaaz on 4/29/23.
//

#import "KSPlayerView.h"
#import "AVFoundation/AVFoundation.h"
#import "UIKit/UIKit.h"
#import "KSPlayerUIView.h"

@interface KSPlayerView ()

@property(strong , nonatomic) KSPlayerUIView *overlayView;//for UserInterface;

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
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        // NSView
        //self.layer.backgroundColor = (__bridge CGColorRef _Nullable)(NSColor.blackColor);
        //self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        
        [(AVPlayerLayer *) [self layer] setPlayer:player];
        
        CGRect overlaySize = self.frame;
        
        _overlayView = [[KSPlayerUIView alloc] initWithFrame:overlaySize];
        //[[[NSBundle mainBundle] loadNibNamed:@"KSOverlayView" owner:self options:nil] objectAtIndex:0];
        
        [self addSubview:_overlayView];
    }

    return self;
}

-(void)drawRect:(CGRect)rect
{
    //NSLog(@"drawing");
    //[super drawRect:rect];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.overlayView.frame = self.bounds;
}

-(id <KSTransport>)transport
{
    //TODO
    return self.overlayView;
}

-(void)setPlayDelegate:(id<KSTransportDelegate>)delegate
{
    [_overlayView setPlayDelegate:delegate];
}


@end
