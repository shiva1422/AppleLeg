//
//  KSFilterRenderer.h
//  PhotoFX
//
//  Created by shivaaz on 12/21/22.
//


#import <UIKit/UIKit.h>
#import "KSMetalView.h"


NS_ASSUME_NONNULL_BEGIN

@interface KSFilterRenderer : NSObject <KSMetalViewDelegate>

-(void)updateTexture:(CVPixelBufferRef)pixelBuffer;


@end

NS_ASSUME_NONNULL_END
