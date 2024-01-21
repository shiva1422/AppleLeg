//
//  TextureUtils.m
//  Metal
//
//  Created by shivaaz on 10/18/22.
//

#import "TextureUtils.h"
@import Metal;

@implementation TextureUtils

+(void)loadTexture
{
    //Loading image
    
    UIImage *image = [UIImage imageNamed:@"allkeys"];//pixels are not directly accessed so below also flip texutre as metal texture starts from top.
    CGImageRef imageRef = [image CGImage];
    // Create a suitable bitmap context for extracting the bits of the image
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *rawData = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t)); NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
    bitsPerComponent, bytesPerRow, colorSpace,
    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big); CGColorSpaceRelease(colorSpace);
    // Flip the context so the positive Y axis points down
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); CGContextRelease(context);
    CGContextRelease(context);
    
    
    //MTL texture
    /*
     A texture descriptor is a lightweight object that specifies the dimensions and format of a texture. When creating a texture, you provide a texture descriptor and receive an object that conforms to the MTLTexture protocol, which is a subprotocol of MTLResource. The properties specified on the texture descriptor (texture type, dimensions, and format) are immutable once the texture has been created, but you can still update the content of the texture as long as the pixel format of the new data matches the pixel format of the receiv- ing texture.
     */
    
    MTLTextureDescriptor *textDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm   width:width height:height   mipmapped:YES];
    
    //create texture with descriptor
   // id<MTLTexture> texture = [self.device newTextureWithDescriptor:textDesc];
    
    /*
     Setting the data in the texture is also quite simple. We create a MTLRegion that represents the entire texture and then tell the texture to replace that region with the raw image bits we previously retrieved from the context:
     */
    
    
    
                                                                                       
}

@end
