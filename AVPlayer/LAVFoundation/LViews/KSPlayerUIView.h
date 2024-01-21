//
//  KSOverlayView.h
//  AVPlayerIOS
//
//  Created by shivaaz on 4/30/23.
//

#import <UIKit/UIKit.h>
#import "../Controllers/KSTransport.h"
/*
 adopts KSTransport protocol to fprovide formal interface for communicting with user actions.
 */
NS_ASSUME_NONNULL_BEGIN

@interface KSPlayerUIView : UIView <KSTransport>

@property (strong, nonatomic)  UIButton *playButton;
@property (strong, nonatomic)  UISlider *seekBar;

@property (weak, nonatomic) id <KSTransportDelegate> delegate;


- (IBAction)togglePlay:(id)sender;

-(void)setPlayDelegate:(id<KSTransportDelegate>)delegate;



@end

NS_ASSUME_NONNULL_END
