//
//  KSFilterRenderer.m
//  PhotoFX
//
//  Created by shivaaz on 12/21/22.
//

#import "KSFilterRenderer.h"
#import "Utils/MTLM.h"
#import "RenderCommon.h"
#include "FilterCommon.h"

//reorder texture coords and indices accordingly as metal order is different texture starts at top
//quad
const KTextVertex quadVerts[]= {
    
    {.position={ 1.0f,  1.0f,0.0,1.0} ,.textCoods={1.0f, 1.0f}},
    {.position={ 1.0f, -1.0f,0.0,1.0},.textCoods={1.0f, 0.0f}},
    {.position={-1.0f, -1.0f,0.0,1.0},.textCoods={0.0f, 0.0f}},
    {.position={-1.0f,  1.0f,0.0,1.0},.textCoods={0.0f, 1.0f}}
};

const KBEIndex quadIndices[] =
{
   0,2,1,0,3,2
};





@interface KSFilterRenderer ()

@property (strong) id<MTLDevice> device;
@property (strong) id<MTLBuffer> vertexBuffer;
@property (strong) id<MTLBuffer> indexBuffer;
@property (strong) id<MTLBuffer> uniformBuffer;
@property (strong) id<MTLTexture> texture;

@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLRenderPipelineState> renderPipelineState;
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (strong) dispatch_semaphore_t displaySemaphore;
@property (assign) NSInteger bufferIndex;
@property (assign) float rotationX, rotationY, time;

@end

@implementation KSFilterRenderer

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
    
    _texture = [self loadTexture:nil];//For now static load;

    NSError *libraryError = NULL;
    NSString *libraryFile = [[NSBundle mainBundle] pathForResource:@"hsi" ofType:@"metallib"];
    id <MTLLibrary> library = [_device newLibraryWithFile:libraryFile error:&libraryError];
    if (!library)
    {
        NSLog(@"Library error: %@", libraryError.localizedDescription);
    }

    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"hsi_vert"];
    pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"hsi_frag"];
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
    
    _vertexBuffer = [self.device newBufferWithBytes:quadVerts
                                                length:sizeof(quadVerts)
                                               options:MTLResourceOptionCPUCacheModeDefault];
    [_vertexBuffer setLabel:@"vertices"];

    _indexBuffer = [self.device newBufferWithBytes:quadIndices
                                               length:sizeof(quadIndices)
                                              options:MTLResourceOptionCPUCacheModeDefault];
    [_indexBuffer setLabel:@"indices"];

    _uniformBuffer = [self.device newBufferWithLength:AlignUp(sizeof(KUniforms), KSBufferAlignment) * KSFilghtBufferCount   options:MTLResourceOptionCPUCacheModeDefault];
                                                
    [_uniformBuffer setLabel:@"uniforms"];
    
    [self updateAnimation:nil duration:0];
}


- (void)updateAnimation:(KSMetalView *)view duration:(NSTimeInterval)duration
{
    self.time += duration;
    self.rotationX += 0.0;//duration * (M_PI / 2);
    self.rotationY += 0.0;//duration * (M_PI / 3);
    float scaleFactor = 1.0;//sinf(5 * self.time) * 0.25 + 1;
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
    const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);

    const vector_float3 cameraTranslation = { 0, 0, 0 };//{ 0, 0, -5 };
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

    [self updateAnimation:view duration:view.frameDuration];

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    MTLRenderPassDescriptor *passDescriptor = [view getCurrentRenderPassDescriptor];

    assert(passDescriptor != nil);
    
    id<MTLRenderCommandEncoder> renderPass = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [renderPass setRenderPipelineState:self.renderPipelineState];
    [renderPass setDepthStencilState:self.depthStencilState];
    [renderPass setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderPass setCullMode:MTLCullModeBack];
    
    assert(_texture);

    const NSUInteger uniformBufferOffset = AlignUp(sizeof(KUniforms), KSBufferAlignment) * self.bufferIndex;

    [renderPass setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [renderPass setVertexBuffer:self.uniformBuffer offset:uniformBufferOffset atIndex:1];
    [renderPass setFragmentTexture:_texture atIndex:0];

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

- (id<MTLTexture>)loadTexture: (NSURL *) url
{
    UIImage *image = [UIImage imageNamed:@"sample"];//pixels are not directly accessed so below also flip texutre as metal texture starts from top.
    assert(image != nil);
    CGImageRef imageRef = [image CGImage];
    // Create a suitable bitmap context for extracting the bits of the image
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *pixels = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t)); NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,
    bitsPerComponent, bytesPerRow, colorSpace,
    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big); CGColorSpaceRelease(colorSpace);
    // Flip the context so the positive Y axis points down
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    
    MTLTextureDescriptor *textDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm   width:width height:height   mipmapped:NO];
      
    
    //create texture with descriptor
    id<MTLTexture> texture = [self.device newTextureWithDescriptor:textDesc];

    //set Texture data.
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [texture replaceRegion:region mipmapLevel:0 withBytes:pixels bytesPerRow:bytesPerRow];
    
    return texture;
    
}
@end
