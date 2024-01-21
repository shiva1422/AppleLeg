//
//  ViewController.m
//  AVPlayerIOS
//
//  Created by shivaaz on 5/31/23.
//

#import "ViewController.h"
#import "../LAVFoundation/Controllers/KSPlayerController.h"
@interface ViewController ()

@property (strong, nonatomic) KSPlayerController *controller;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *assetURL =[[NSBundle mainBundle] URLForResource:@"desparado" withExtension:@"mov"];
    //NSURL *assetURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                        //pathForResource:@"sample" ofType:@"mp4"]];
   // assert(assetURL != nil);
    self.controller = [[KSPlayerController alloc] initWithURL:assetURL];
    UIView *playerView = self.controller.getVideoTarget;//KSPlayerView;
   // playerView.frame = self.view.frame;
    [self.view addSubview:playerView];
    

    // Do any additional setup after loading the view.
}


@end
