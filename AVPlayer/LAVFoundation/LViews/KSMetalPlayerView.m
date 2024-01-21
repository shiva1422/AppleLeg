//
//  KSCustomPlayerView.m
//  AVPlayerIOS
//
//  Created by shivaaz on 6/3/23.
//

#import "KSMetalPlayerView.h"
#import "KSPlayerUIView.h"
#import "../MetalLib/Renderer/KSFilterRenderer.h"

@interface KSMetalPlayerView ()

@property(strong , nonatomic) KSPlayerUIView *overlayView;//for UserInterface;
@property (strong) CADisplayLink *displayLink;
@property(strong)AVPlayerItemVideoOutput *videoSource;
@property(strong ,nonatomic)KSFilterRenderer *renderer;

@end


@implementation KSMetalPlayerView


+ (id)layerClass
{
  return [CAMetalLayer class];
}

-(id)initWithPlayer : (AVPlayer *)player
{
    
    
    self = [super initWithFrame:[[UIScreen mainScreen]  bounds]];
    
    if(self)
    {
        // UIView
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        // NSView
        //self.layer.backgroundColor = (__bridge CGColorRef _Nullable)(NSColor.blackColor);
        //self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        
       // [(AVPlayerLayer *) [self layer] setPlayer:player];
        
        CGRect overlaySize = self.frame;
        
        _overlayView = [[KSPlayerUIView alloc] initWithFrame:overlaySize];
        //[[[NSBundle mainBundle] loadNibNamed:@"KSOverlayView" owner:self options:nil] objectAtIndex:0];
        
        [self addSubview:_overlayView];
        
        _renderer = [KSFilterRenderer new];
        self.delegate = _renderer;
    }

    return self;
}

-(void)drawRect:(CGRect)rect
{
    NSLog(@"drawing");
    [super drawRect:rect];
}

- (void)didMoveToSuperview
{
    //Todo invalidate display link at the start of play,end and seeking() or use a custom clock.
    [super didMoveToSuperview];
    if (self.superview)
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    else
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)displayLinkDidFire:(CADisplayLink *)displayLink
{
   
    NSLog(@"onDisplayLinkFired");
    [super displayLinkDidFire:displayLink];
    //Get CVPixelBuffer(check this is metal compatible buffer) from AVPlayerItermVideoOutput and create texture and render to View.
    if(_videoSource)
    {
        NSLog(@"check Video Refresh");
        CMTime pts = [self.videoSource itemTimeForHostTime:displayLink.timestamp];
        if([self.videoSource hasNewPixelBufferForItemTime:pts])
        {
            NSLog(@"onVideo Refresh");
            CVPixelBufferRef pixBuff = NULL;
            CMTime presentationItemTime = pts;
            //self->myLastHostTime = inOutputTime->hostTime;//todo //previous pts
            pixBuff = [[self videoSource] copyPixelBufferForItemTime:pts itemTimeForDisplay:&presentationItemTime];
                 
                        // Use pixBuff here
                        // presentationItemTime is the item time appropriate for
                        // the next screen refresh
            
            if(pixBuff)
            {
                [_renderer updateTexture:pixBuff];
            }
            
                
        CVBufferRelease( pixBuff );
    }
    }
    else
    {
        NSLog(@"TODO");//from apple source;
    }
}

-(void)setAVPlayerVideoOutSource:(AVPlayerItemVideoOutput *)videoSource
{
    self.videoSource = videoSource;
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
