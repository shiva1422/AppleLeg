//
//  KSMetalView.m
//  Metal
//
//  Created by shivaaz on 10/15/22.
//

#import "KSMetalView.h"
static  bool isFirst = true;


@interface KSMetalView()

@property (strong) id<CAMetalDrawable> currentDrawable;
@property (assign) NSTimeInterval frameDuration;
@property (strong) id<MTLTexture> depthTexture;
@property (strong) CADisplayLink *displayLink;

@end

//Change the Custom Class of the view in the main storyboard file to this view
@implementation KSMetalView


+ (id)layerClass
{
  return [CAMetalLayer class];
}

-(CAMetalLayer *)metalLayer
{
    return (CAMetalLayer *)self.layer;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder]))
    {
        //common
        _fps = 60;
        _clearColor = MTLClearColorMake(0, 0, 0, 1);
        self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        
        self.metalLayer.device = MTLCreateSystemDefaultDevice();

    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame device:(id<MTLDevice>)device
{
    if ((self = [super initWithFrame:frame]))
    {
        //common
        _fps = 60;
        _clearColor = MTLClearColorMake(1, 1, 1, 1);
        self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        
        self.metalLayer.device = device;
    }

    return self;
}

- (void)dealloc
{
    [_displayLink invalidate];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    // During the first layout pass, we will not be in a view hierarchy, so we guess our scale
    CGFloat scale = [UIScreen mainScreen].scale;
    
    // If we've moved to a window by the time our frame is being set, we can take its scale as our own
    if (self.window)
    {
        scale = self.window.screen.scale;
    }
    
    CGSize drawableSize = self.bounds.size;
    
    // Since drawable size is in pixels, we need to multiply by the scale to move from points to pixels
    drawableSize.width *= scale;
    drawableSize.height *= scale;

    self.metalLayer.drawableSize = drawableSize;

    [self createDepthTexture];
    
    NSLog(@"setFrame");
}

- (void)createDepthTexture
{
    CGSize drawableSize = self.metalLayer.drawableSize;

    NSLog(@"creating depth texture");
    NSLog(@"depth texture %lu %lu %f %f",(unsigned long)self.depthTexture.width,self.depthTexture.height,drawableSize.width,drawableSize.height);

    if ([self.depthTexture width] != drawableSize.width ||
        [self.depthTexture height] != drawableSize.height || isFirst)
    {
        NSLog(@"depth texture %lu %lu %f %f",(unsigned long)self.depthTexture.width,(unsigned long)self.depthTexture.height,drawableSize.width,drawableSize.height);
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float  width:drawableSize.width  height:drawableSize.height mipmapped:NO];
                                                                                       
        desc.usage = MTLTextureUsageRenderTarget;
        desc.storageMode = MTLStorageModePrivate;
        
        self.depthTexture = [self.metalLayer.device newTextureWithDescriptor:desc];
        
//        assert(self.depthTexture != nil);
        NSLog(@"created depth texture");
        isFirst = false;

    }
}

- (void)setColorPixelFormat:(MTLPixelFormat)colorPixelFormat
{
    self.metalLayer.pixelFormat = colorPixelFormat;
}

- (MTLPixelFormat)colorPixelFormat
{
    return self.metalLayer.pixelFormat;
}


- (void)didMoveToSuperview
{
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



- (void)didMoveToWindow
{
        const NSTimeInterval idealFrameDuration = (1.0 / 60);
        const NSTimeInterval targetFrameDuration = (1.0 / self.fps);
        const NSInteger frameInterval = round(targetFrameDuration / idealFrameDuration);

        if (self.window)
        {
            [self.displayLink invalidate];
             self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
            //TODO deprecated
             self.displayLink.frameInterval = frameInterval;
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

    self.currentDrawable = self.metalLayer.nextDrawable;
    self.frameDuration = displayLink.duration;
    if ( self.currentDrawable && self.depthTexture != nil && [self.delegate respondsToSelector:@selector(onRender:)])
    {
        [self.delegate onRender:self];
    }
    else
    {
        NSLog(@"Drawable error");
    }
    
}

- (MTLRenderPassDescriptor *)getCurrentRenderPassDescriptor
{
    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];


    passDescriptor.colorAttachments[0].texture = [self.currentDrawable texture];
    passDescriptor.colorAttachments[0].clearColor = self.clearColor;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;

    assert(self.depthTexture != nil);
    passDescriptor.depthAttachment.texture = self.depthTexture;
    passDescriptor.depthAttachment.clearDepth = 1.0;
    passDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    passDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;

    return passDescriptor;
}


@end
