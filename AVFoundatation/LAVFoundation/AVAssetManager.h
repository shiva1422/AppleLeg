//
//  AVAssetManager.h
//  AVFoundatation
//
//  Created by shivaaz on 4/28/23.
//

#ifndef AVAssetManager_h
#define AVAssetManager_h

@interface AVAssetManager : NSObject

+(void)loadAssetPropsAsync :(NSURL *)assetURL;

@end
#endif /* AVAssetManager_h */
