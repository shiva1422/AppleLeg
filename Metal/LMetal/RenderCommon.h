//
//  KSRenderer.h
//  Metal
//
//  Created by shivaaz on 10/18/22.
//

#import <UIKit/UIKit.h>
#import "KSMetalView.h"
#import "Utils/MTLM.h"
#import "Metal/Metal.h"
#import "QuartzCore/CAMetalLayer.h"
#import "simd/simd.h"



typedef struct{
    
    vector_float4 position;
    vector_float2 textCoods;
    
} KTextVertex;//TExture only vertex 2d;

typedef enum KVertexInputIndex
{
    KVertexInputIndexVertices = 0,
    KVertexInputIndexViewportSize = 1
    
} KVertexInputIndex;

typedef enum KTextureIndex
{
    KTexttureIndexBaseColor = 0
    
} KTexttureIndex;



typedef uint16_t KBEIndex;//buffer Elementary

static const NSInteger KSFilghtBufferCount = 3;

static inline uint64_t AlignUp(uint64_t n, uint32_t alignment)
{
    return ((n + alignment - 1) / alignment) * alignment;
}

static const uint32_t KSBufferAlignment = 256;


typedef struct {
    
vector_float4 position;
    
vector_float4 color;
    
} KVertex;

typedef struct {
    
matrix_float4x4 mvpMatrix;
    
} KUniforms;

