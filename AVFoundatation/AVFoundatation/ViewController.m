//
//  ViewController.m
//  AVFoundatation
//
//  Created by shivaaz on 5/28/23.
//

#import "ViewController.h"
#import "../LAVFoundation/AVAssetManager.h"
#import "../LAVFoundation/KSPlayer.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    //NSURL *url = [[NSBundle mainBundle] URLForResource:@"rakkamma" withExtension:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bujji" ofType:@"mp3"]];
    NSLog(@"opening asset props %@",url.path);

    [AVAssetManager loadAssetPropsAsync:url];
    
    NSURL *playerAsset = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mov"];
    
    KSPlayer *player = [[KSPlayer alloc] initWithURL:playerAsset];
    
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
