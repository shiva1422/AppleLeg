//
//  Triangle.h
//  Metal
//
//  Created by shivaaz on 10/15/22.
//

#ifndef Triangle_h
#define Triangle_h

@import Metal;
@import simd;


typedef struct {
    
vector_float4 position;
    
vector_float4 color;
    
} KVertex;


@interface Triangle : NSObject

-(void)allocBuffer:(id<MTLDevice>) device;

@end

#endif /* Triangle_h */
