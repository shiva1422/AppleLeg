//
//  KSPlayerController.h
//  AVFoundatation
//
//  Created by shivaaz on 4/30/23.
//

#import <UIKit/UIKit.h>


//Not a ViewController
NS_ASSUME_NONNULL_BEGIN

@interface KSPlayerController : NSObject

-(id)initWithURL:(NSURL *)assetURL;

//@property(strong,nonatomic,readonly) UIView *view;//KSPlayerView

-(UIView *)getVideoTarget;

@end

NS_ASSUME_NONNULL_END
