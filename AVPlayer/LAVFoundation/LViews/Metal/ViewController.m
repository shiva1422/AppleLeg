//
//  ViewController.m
//  Metal
//
//  Created by shivaaz on 5/28/23.
//

#import "ViewController.h"
#import "../LMetal/KSTextureRenderer.h"
#import "../LMetal/KSCubeMapRenderer.h"
#import "../LMetal/KSFilterRenderer.h"

@interface ViewController ()
//@property (nonatomic, strong) KSCubeMapRenderer *renderer;
@property (nonatomic, strong) KSFilterRenderer *renderer;

@end

@implementation ViewController

- (KSMetalView *)metalView
{
    return (KSMetalView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.renderer = [KSFilterRenderer new];
    KSMetalView *mv = (KSMetalView *)self.view;
//mv.layer = [mv metalLayer];
    mv.delegate  = _renderer;
    
    
   

}


@end
