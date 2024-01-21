//
//  KSPlayer.h
//  AVFoundatation
//
//  Created by shivaaz on 4/29/23.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
NS_ASSUME_NONNULL_BEGIN

@interface KSPlayer : NSObject



-(instancetype)initWithURL:(NSURL *)assetURL;

-(NSInteger)preparePlayer;//

@end

NS_ASSUME_NONNULL_END
