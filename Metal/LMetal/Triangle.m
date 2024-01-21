//
//  Triangle.m
//  Metal
//
//  Created by shivaaz on 10/15/22.
//

#import <Foundation/Foundation.h>
#import "Triangle.h"

@interface Triangle()
{
    id<MTLBuffer> vertexBuffer;
}

@end


@implementation Triangle


-(void)allocBuffer:(id<MTLDevice>) device
{
    
    static const KVertex vertices[] = {
        {.position={ 0.0, 0.5,0,1},.color={1,0,0,1}},
        {.position={-0.5,-0.5,0,1},.color={0,1,0,1}},
        {.position={ 0.5,-0.5,0,1},.color={0,0,1,1}}
        
    };
    
    vertexBuffer = [device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceOptionCPUCacheModeDefault];
}

@end
