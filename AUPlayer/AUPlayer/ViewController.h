//
//  ViewController.h
//  AUPlayer
//
//  Created by shivaaz on 5/26/23.
//

#import <Cocoa/Cocoa.h>

struct AudioGraphPlayerWrap;

@interface ViewController : NSViewController{
    struct AudioGraphPlayerWrap *player;
}

@end

