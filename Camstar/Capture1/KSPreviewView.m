//
//  KSPreviewView.m
//  Camstar
//
//  Created by shivaaz on 7/7/23.
//

#import "KSPreviewView.h"

@implementation KSPreviewView

+(Class) layerClass{
    
    return [AVCaptureVideoPreviewLayer class];
}

-(void)setSession:(AVCaptureSession *)session
{
    
    //direct caputre output to layer
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

-(AVCaptureSession *)session
{
   return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

//convert touch point from screenCoords to camera Coordinates.
-(CGPoint)captureDevicePointForPoint:(CGPoint)point
{
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
    
    
}

@end
