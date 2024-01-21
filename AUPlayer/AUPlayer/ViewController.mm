//
//  ViewController.m
//  AUPlayer
//
//  Created by shivaaz on 5/26/23.
//

#import "ViewController.h"
#import "../LAudioUnits/AudioGraph.hpp"



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *audioUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bujji" ofType:@"mp3"]];
    
    if(audioUrl == nil)
        NSLog(@"error AssetNot Found");
    else
    {
        NSString *str = audioUrl.absoluteString;
        player = new AudioGraphPlayerWrap(str.UTF8String);
        player->play();
    }
    
    
    // Do any additional setup after loading the view.
    
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
