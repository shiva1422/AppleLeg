//
//  KSRenderer.m
//  Metal
//
//  Created by shivaaz on 10/18/22.
//

#import "KSModelRenderer.h"
#import "Utils/MTLM.h"
#import "RenderCommon.h"

static const KVertex triangleVerts[] = {
    
    {.position={ 0.0, 0.5,0,1},.color={1,0,0,1}},
    {.position={-0.5,-0.5,0,1},.color={0,1,0,1}},
    {.position={ 0.5,-0.5,0,1},.color={0,0,1,1}}
    
};

//indexed
const KVertex cubeVerts[] = {
{   .position={-1, 1, 1,1},.color={0,1,1,1}},
    {.position={-1,-1, 1,1},.color={0,0,1,1}},
    {.position={ 1,-1, 1,1},.color={1,0,1,1}},
    {.position={ 1, 1, 1,1},.color={1,1,1,1}},
    {.position={-1, 1,-1,1},.color={0,1,0,1}},
    {.position={-1,-1,-1,1},.color={0,0,0,1}},
    {.position={ 1,-1,-1,1},.color={1,0,0,1}},
    {.position={ 1, 1,-1,1},.color={1,1,0,1}}
};

 
const KBEIndex cubeIndices[] =
{
    3,2,6,6,7,3,
    4,5,1,1,0,4,
    4,0,3,3,7,4,
    1,5,6,6,2,1,
    0,1,2,2,3,0,
    7,6,5,5,4,7
};




@interface KSRenderer ()

@property (strong) id<MTLDevice> device;
@property (strong) id<MTLBuffer> vertexBuffer;
@property (strong) id<MTLBuffer> indexBuffer;
@property (strong) id<MTLBuffer> uniformBuffer;
@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLRenderPipelineState> renderPipelineState;
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (strong) dispatch_semaphore_t displaySemaphore;
@property (assign) NSInteger bufferIndex;
@property (assign) float rotationX, rotationY, time;
@end

@implementation KSRenderer

- (instancetype)init
{
    if ((self = [super init]))
    {
        _device = MTLCreateSystemDefaultDevice();
        _displaySemaphore = dispatch_semaphore_create(KSFilghtBufferCount);
        [self createPipeline];
        [self createBuffers];
    }

    return self;
}


- (void)createPipeline
{
    self.commandQueue = [self.device newCommandQueue];

    NSError *libraryError = NULL;
    NSString *libraryFile = [[NSBundle mainBundle] pathForResource:@"baseMVP" ofType:@"metallib"];
    id <MTLLibrary> library = [_device newLibraryWithFile:libraryFile error:&libraryError];
    if (!library)
    {
        NSLog(@"Library error: %@", libraryError.localizedDescription);
    }

    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"v_mvp"];
    pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"f_flatcolor"];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;

    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    self.depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];

    NSError *error = nil;
    self.renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                           error:&error];

    if (!self.renderPipelineState)
    {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }

    self.commandQueue = [self.device newCommandQueue];
}

- (void)createBuffers
{
    
    _vertexBuffer = [self.device newBufferWithBytes:cubeVerts
                                                length:sizeof(cubeVerts)
                                               options:MTLResourceOptionCPUCacheModeDefault];
    [_vertexBuffer setLabel:@"vertices"];

    _indexBuffer = [self.device newBufferWithBytes:cubeIndices
                                               length:sizeof(cubeIndices)
                                              options:MTLResourceOptionCPUCacheModeDefault];
    [_indexBuffer setLabel:@"indices"];

    _uniformBuffer = [self.device newBufferWithLength:AlignUp(sizeof(KUniforms), KSBufferAlignment) * KSFilghtBufferCount   options:MTLResourceOptionCPUCacheModeDefault];
                                                
    [_uniformBuffer setLabel:@"uniforms"];
}


- (void)updateMVP:(KSMetalView *)view duration:(NSTimeInterval)duration
{
    self.time += duration;
    self.rotationX += duration * (M_PI / 2);
    self.rotationY += duration * (M_PI / 3);
    float scaleFactor = sinf(5 * self.time) * 0.25 + 1;
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
    const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);

    const vector_float3 cameraTranslation = { 0, 0, -5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);

    const CGSize drawableSize = view.metalLayer.drawableSize;
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1;
    const float far = 100;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect, fov, near, far);

    KUniforms uniforms;
    uniforms.mvpMatrix = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix));

    const NSUInteger uniformBufferOffset = AlignUp(sizeof(KUniforms), KSBufferAlignment) * self.bufferIndex;
    memcpy((uint8_t *)[self.uniformBuffer contents] + uniformBufferOffset, &uniforms, sizeof(uniforms));
}

- (void)onRender:(KSMetalView *)view
{
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);

    view.clearColor = MTLClearColorMake(0, 0.0, 0.0, 1);

    [self updateMVP:view duration:view.frameDuration];

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    MTLRenderPassDescriptor *passDescriptor = [view getCurrentRenderPassDescriptor];

    assert(passDescriptor != nil);
    
    id<MTLRenderCommandEncoder> renderPass = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [renderPass setRenderPipelineState:self.renderPipelineState];
    [renderPass setDepthStencilState:self.depthStencilState];
    [renderPass setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderPass setCullMode:MTLCullModeBack];

    const NSUInteger uniformBufferOffset = AlignUp(sizeof(KUniforms), KSBufferAlignment) * self.bufferIndex;

    [renderPass setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [renderPass setVertexBuffer:self.uniformBuffer offset:uniformBufferOffset atIndex:1];

    const MTLIndexType KBEIndexType = MTLIndexTypeUInt16;

    [renderPass drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                           indexCount:[self.indexBuffer length] / sizeof(KBEIndex)
                            indexType:KBEIndexType
                          indexBuffer:self.indexBuffer
                    indexBufferOffset:0];

    [renderPass endEncoding];

    [commandBuffer presentDrawable:view.currentDrawable];

    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        self.bufferIndex = (self.bufferIndex + 1) % KSFilghtBufferCount;
        dispatch_semaphore_signal(self.displaySemaphore);
    }];
    
    [commandBuffer commit];
}



@end
