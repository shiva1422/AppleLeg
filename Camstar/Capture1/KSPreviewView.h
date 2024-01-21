//
//  KSPreviewView.h
//  Camstar
//
//  Created by shivaaz on 7/7/23.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol KSPreviewViewDelegate  <NSObject>

-(void)onFoucusAtPoint:(CGPoint)point;
-(void)onExposeAtPoint:(CGPoint)point;
-(void)onResetFocusAndExposure;

@end

@interface KSPreviewView : UIView

@property(strong , nonatomic) AVCaptureSession *session;
@property(weak,nonatomic) id<KSPreviewViewDelegate> delegate;
@property(nonatomic) BOOL bEnableTapToFocus;
@property(nonatomic) BOOL bEnableTapToExpose;

@end

NS_ASSUME_NONNULL_END
