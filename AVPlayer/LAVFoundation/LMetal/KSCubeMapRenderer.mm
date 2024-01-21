//
//  KSRenderer.m
//  Metal
//
//  Created by shivaaz on 10/18/22.
//

#import "KSCubeMapRenderer.h"
#import "RenderCommon.h"
//indexed


/*
 Cube map texture coordinates work somewhat differently than 2D texture coordinates. The first difference is that three coordinates are required to sample a cube map, rather than two. The three coordinates are treated as a ray originating at the center of the cube, intersecting the face at a particular point on the cube. In this way, cube texture coordi- nates represent a direction rather than a particular point.
 
 //cube map is lefthanded;//texturedirections are from within the cube self not word

 */


//cubemap vertex
typedef struct
{
    simd_float4 position;
    simd_float4 normal;
} CVertex;
//face coords + texturecoods
static float cubeMesh[] =
{
    // + Y
    -1.0,  1.0,  1.0, 1.0,  0.0, -1.0,  0.0, 0.0,
     1.0,  1.0,  1.0, 1.0,  0.0, -1.0,  0.0, 0.0,
     1.0,  1.0, -1.0, 1.0,  0.0, -1.0,  0.0, 0.0,
    -1.0,  1.0, -1.0, 1.0,  0.0, -1.0,  0.0, 0.0,
    // -Y
    -1.0, -1.0, -1.0, 1.0,  0.0,  1.0,  0.0, 0.0,
     1.0, -1.0, -1.0, 1.0,  0.0,  1.0,  0.0, 0.0,
     1.0, -1.0,  1.0, 1.0,  0.0,  1.0,  0.0, 0.0,
    -1.0, -1.0,  1.0, 1.0,  0.0,  1.0,  0.0, 0.0,
    // +Z
    -1.0, -1.0,  1.0, 1.0,  0.0,  0.0, -1.0, 0.0,
     1.0, -1.0,  1.0, 1.0,  0.0,  0.0, -1.0, 0.0,
     1.0,  1.0,  1.0, 1.0,  0.0,  0.0, -1.0, 0.0,
    -1.0,  1.0,  1.0, 1.0,  0.0,  0.0, -1.0, 0.0,
    // -Z
     1.0, -1.0, -1.0, 1.0,  0.0,  0.0,  1.0, 0.0,
    -1.0, -1.0, -1.0, 1.0,  0.0,  0.0,  1.0, 0.0,
    -1.0,  1.0, -1.0, 1.0,  0.0,  0.0,  1.0, 0.0,
     1.0,  1.0, -1.0, 1.0,  0.0,  0.0,  1.0, 0.0,
    // -X
    -1.0, -1.0, -1.0, 1.0,  1.0,  0.0,  0.0, 0.0,
    -1.0, -1.0,  1.0, 1.0,  1.0,  0.0,  0.0, 0.0,
    -1.0,  1.0,  1.0, 1.0,  1.0,  0.0,  0.0, 0.0,
    -1.0,  1.0, -1.0, 1.0,  1.0,  0.0,  0.0, 0.0,
    // +X
     1.0, -1.0,  1.0, 1.0, -1.0,  0.0,  0.0, 0.0,
     1.0, -1.0, -1.0, 1.0, -1.0,  0.0,  0.0, 0.0,
     1.0,  1.0, -1.0, 1.0, -1.0,  0.0,  0.0, 0.0,
     1.0,  1.0,  1.0, 1.0, -1.0,  0.0,  0.0, 0.0,
};

static uint16_t cubeMapIndices[] =
{
     0,  3,  2,  2,  1,  0,
     4,  7,  6,  6,  5,  4,
     8, 11, 10, 10,  9,  8,
    12, 15, 14, 14, 13, 12,
    16, 19, 18, 18, 17, 16,
    20, 23, 22, 22, 21, 20,
};


@interface  KSCubeMapRenderer()

@property (strong) id<MTLDevice> device;
@property (strong) id<MTLBuffer> vertexBuffer;
@property (strong) id<MTLBuffer> indexBuffer;
@property (strong) id<MTLBuffer> uniformBuffer;
@property (strong) id<MTLTexture> texture;
@property (nonatomic,strong) id<MTLSamplerState> samplerState;


@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLRenderPipelineState> renderPipelineState;
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (strong) dispatch_semaphore_t displaySemaphore;
@property (assign) NSInteger bufferIndex;
@property (assign) float rotationX, rotationY,rotationZ, time;
@end

@implementation KSCubeMapRenderer

- (instancetype)init
{
    if ((self = [super init]))
    {
        _device = MTLCreateSystemDefaultDevice();
        _commandQueue = [self.device newCommandQueue];

        _displaySemaphore = dispatch_semaphore_create(KSFilghtBufferCount);
        [self createPipeline];
        [self createResources];
    }

    return self;
}


- (void)createPipeline
{
        MTLVertexDescriptor *vertexDescriptor = [MTLVertexDescriptor new];
        vertexDescriptor.attributes[0].bufferIndex = 0;//pos attib
        vertexDescriptor.attributes[0].offset = 0;
        vertexDescriptor.attributes[0].format = MTLVertexFormatFloat4;
        
        vertexDescriptor.attributes[1].offset = sizeof(simd_float4);//normal attrib
        vertexDescriptor.attributes[1].format = MTLVertexFormatFloat4;
        vertexDescriptor.attributes[1].bufferIndex = 0;
        
        vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;//whole vertex wi
        vertexDescriptor.layouts[0].stride = sizeof(CVertex);
            
    

     /*   NSError *libraryError = NULL;
        NSString *libraryFile = [[NSBundle mainBundle] pathForResource:@"metallib/cubemap" ofType:@"metallib"];
      */
    
       // id <MTLLibrary> library = [_device newLibraryWithFile:libraryFile error:&libraryError];
        id <MTLLibrary> library  = [_device newDefaultLibrary];

        if (!library)
        {
         // NSLog(@"Library error: %@", libraryError.localizedDescription);
        }

        MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
        pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vert"];
        pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"frag"];
        pipelineDescriptor.vertexDescriptor = vertexDescriptor;
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

}

- (void)createResources
{
    _texture = [self createCubemapTexture];//For now static load;
    
    _vertexBuffer = [self.device newBufferWithBytes:cubeMesh
                                                length:sizeof(cubeMesh)
                                               options:MTLResourceOptionCPUCacheModeDefault];
    
    [_vertexBuffer setLabel:@"vertices"];
    
    _indexBuffer = [self.device newBufferWithBytes:cubeMapIndices
                                               length:sizeof(cubeMapIndices)
                                              options:MTLResourceOptionCPUCacheModeDefault];
    
    [_indexBuffer setLabel:@"indices"];
    
    
    _uniformBuffer = [self.device newBufferWithLength:AlignUp(sizeof(KUniforms), KSBufferAlignment) * KSFilghtBufferCount   options:MTLResourceOptionCPUCacheModeDefault];
                                                
    [_uniformBuffer setLabel:@"uniforms"];
    
    [self updateAnimation:nil duration:0];
    
    MTLSamplerDescriptor *samplerDescriptor = [MTLSamplerDescriptor new];
    samplerDescriptor.minFilter = MTLSamplerMinMagFilterNearest;
    samplerDescriptor.magFilter = MTLSamplerMinMagFilterLinear;
    samplerDescriptor.mipFilter = MTLSamplerMipFilterLinear;
    self.samplerState = [self.device newSamplerStateWithDescriptor:samplerDescriptor];

}


- (void)updateAnimation:(KSMetalView *)view duration:(NSTimeInterval)duration
{
    self.time += duration;
    self.rotationX += duration * (M_PI / 60);
    self.rotationY += 0;//duration * (M_PI / 60);
    self.rotationZ += duration * (M_PI / 2);

    float scaleFactor = 2.0;//sinf(5 * self.time) * 0.25 + 1;
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
    const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);
    

    const vector_float3 cameraTranslation = { 0, 0, -5};//{ 0, 0, -5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);

    const CGSize drawableSize = view.metalLayer.drawableSize;
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;//same as camZTranslate?
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
    NSLog(@"drawing");
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
    [renderPass setCullMode:MTLCullModeFront];//TODO
    
    assert(_texture);
    

    const NSUInteger uniformBufferOffset = AlignUp(sizeof(KUniforms), KSBufferAlignment) * self.bufferIndex;

    [renderPass setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [renderPass setVertexBuffer:self.uniformBuffer offset:uniformBufferOffset atIndex:1];
    [renderPass setFragmentTexture:_texture atIndex:0];
    [renderPass setFragmentSamplerState:self.samplerState atIndex:0];

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
    
    //MTL texture
    /*
     A texture descriptor is a lightweight object that specifies the dimensions and format of a texture. When creating a texture, you provide a texture descriptor and receive an object that conforms to the MTLTexture protocol, which is a subprotocol of MTLResource. The properties specified on the texture descriptor (texture type, dimensions, and format) are immutable once the texture has been created, but you can still update the content of the texture as long as the pixel format of the new data matches the pixel format of the receiv- ing texture.
     */
    
    MTLTextureDescriptor *textDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm   width:width height:height   mipmapped:NO];
      
    
    //create texture with descriptor
    id<MTLTexture> texture = [self.device newTextureWithDescriptor:textDesc];
    
    /*
     Setting the data in the texture is also quite simple. We create a MTLRegion that represents the entire texture and then tell the texture to replace that region with the raw image bits we previously retrieved from the context:
     */
    
    MTLRegion region = MTLRegionMake2D(0, 0, width, height); [texture replaceRegion:region mipmapLevel:0 withBytes:pixels
   bytesPerRow:bytesPerRow];
    
    return texture;
    
}

-(id <MTLTexture>)createCubemapTexture
{
    //cubemaps are left handed coords
    
    NSString *imagePath = @"duck.jpg";
    UIImage *image = [UIImage imageNamed:imagePath];//pixels are not directly accessed so below also flip texutre as metal texture starts from top.
    assert(image != nil);
    CGImageRef imageRef = [image CGImage];
    // Create a suitable bitmap context for extracting the bits of the image
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGFloat scale = image.scale;

    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *pixels = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t));
    NSUInteger bytesPerPixel = 4;
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
    
   
    //cube texture has 6 images
    const CGFloat cubeSize = width * scale;//Scale?scale is 1.0?
    bytesPerRow = bytesPerPixel * cubeSize;
    const NSUInteger bytesPerImage = bytesPerRow * cubeSize;
    NSLog(@"cube texture cubeSize %f",cubeSize);

    //
    MTLTextureDescriptor *textDesc = [MTLTextureDescriptor textureCubeDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm size:cubeSize mipmapped:YES];
      
    
    //create texture with descriptor
    id<MTLTexture> texture = [self.device newTextureWithDescriptor:textDesc];
    
    
   /*texture slice direction
       faceno        texture face
        0               +x
        1               -x
        2               +y
        3               -y
        4               +z
        5                -z
        
    */
    
    //6 faces = 6 slices
    MTLRegion region = MTLRegionMake2D(0, 0, width, width);//TODO cube texture should be square so widht = height;

    NSLog(@"cubetexture width %lu height  %lu scale %f",(unsigned long)width,height,scale);
    //width * scale ?above check
    for(int slice = 0 ;slice <6;++slice)
    {
        UIImage *image = [UIImage imageNamed:imagePath];
        uint8_t *imageData = [KSCubeMapRenderer dataForImage:image];
      //  NSAssert(image.size.width == cubeSize && image.size.height == cubeSize, @"Cube map images must be square and uniformly-sized");
                
        [texture replaceRegion:region
                           mipmapLevel:0
                                 slice:slice
                             withBytes:imageData
                           bytesPerRow:bytesPerRow
                         bytesPerImage:bytesPerImage];
                free(imageData);
    }
    
    id<MTLCommandBuffer> mipmapCommandBuffer = [_commandQueue commandBuffer];
    id<MTLBlitCommandEncoder> blitCommandEncoder = [mipmapCommandBuffer blitCommandEncoder];
    [blitCommandEncoder generateMipmapsForTexture:texture];
    [blitCommandEncoder endEncoding];
    [mipmapCommandBuffer commit];
    
    
    return texture;
    
}
+ (uint8_t *)dataForImage:(UIImage *)image
{
    CGImageRef imageRef = [image CGImage];
    
    // Create a suitable bitmap context for extracting the bits of the image
    const NSUInteger width = CGImageGetWidth(imageRef);
    const NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *rawData = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t));
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * width;
    const NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    return rawData;
}
@end
