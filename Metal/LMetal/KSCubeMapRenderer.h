//
//  KSFilterRenderer.h
//  Metal
//
//  Created by shivaaz on 10/18/22.
//

#import <UIKit/UIKit.h>
#import "KSMetalView.h"


NS_ASSUME_NONNULL_BEGIN

@interface KSCubeMapRenderer : NSObject <KSMetalViewDelegate>

+(uint8_t *)dataForImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
