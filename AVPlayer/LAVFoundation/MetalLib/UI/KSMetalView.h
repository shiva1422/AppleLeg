//
//  KSMetalView.h
//  Metal
//
//  Created by shivaaz on 10/15/22.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>


NS_ASSUME_NONNULL_BEGIN

 
@protocol KSMetalViewDelegate;

@interface KSMetalView : UIView

//Backing CA metal layer for the view
@property (readonly) CAMetalLayer *metalLayer;

//color attachment pixel format
@property (nonatomic) MTLPixelFormat pixelFmt;

//color to clear at the beginning of render pass
@property (nonatomic, assign) MTLClearColor clearColor;


@property (nonatomic) NSInteger fps;

//delegate for the view ,resonsible for drawing
@property(nonatomic,weak) id<KSMetalViewDelegate> delegate;

/*
 mems valid only in the delageates drawInView context callback   start
 */

//duration of previous frame.
@property (nonatomic, readonly) NSTimeInterval frameDuration;

@property (nonatomic, readonly) id<CAMetalDrawable> currentDrawable;

 /*
  mems valid only in the delageates drawInView context callback end;
  */


//renderpassDesc configured to use current drawables texture as primary color attachment and internal depth texture of same size as its depth attachment texture.
@property (nonatomic, readonly) MTLRenderPassDescriptor *currentRenderPassDescriptor;

-(MTLRenderPassDescriptor *)getCurrentRenderPassDescriptor;

- (void)displayLinkDidFire:(CADisplayLink *)displayLink;//to use in sub class.



//- (instancetype)initWithCoder:(NSCoder *)decoder;//for now loading from story board later also override init;
//- (CAMetalLayer *)getMetalLayer;

   
@end



@protocol KSMetalViewDelegate <NSObject>

/*
 call once per frame any of the properties of the view can be accessed and request currentRederpassDesc as well.
 */
-(void)onRender:(KSMetalView *)view;

@end

NS_ASSUME_NONNULL_END
