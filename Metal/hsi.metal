//
//  Texture.metal
//  PhotoFX
//
//Created by shivaaz on 10/15/22.
//

#include <metal_stdlib>
#include "ShaderCommon.h"
/*
 xcrun -sdk iphonesimulator metal -c hsi.metal -o hsi.air &&
 xcrun -sdk iphonesimulator metallib hsi.air -o hsi.metallib && rm hsi.air
 */


float3 hsiToRgb(float3 hsi);
float3 rgbToHsi(float3 rgb);


struct Vertex
{
    float4 position [[position]];
    float2 uvCoods;
};

struct Uniforms {
    
float4x4 mvpMatrix;
float params[MAX_PARAM_COUNT];
    
};

vertex Vertex hsi_vert(const device Vertex *vertices [[buffer(0)]],
                    constant Uniforms *uniforms   [[buffer(1)]],
                    uint vid [[vertex_id]])
{
    Vertex vout ;
    vout.position = vertices[vid].position;//uniforms->mvpMatrix * vertices[vid].position;
    vout.uvCoods = vertices[vid].uvCoods;
    return vout;
    
}

fragment float4 hsi_frag(Vertex inVertex [[stage_in]] ,texture2d<float> text [[ texture(0) ]])
{
    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);
    float4 out = text.sample(textureSampler, inVertex.uvCoods);
    //sampledColor = float4(sampledColor.r,0.0,0.0,sampledColor.a);
   // float3 hsi = rgbToHsi(float3(out.r*255.0,out.g*255.0,out.b*255.0));
    
  //  out = float4(hsiToRgb(float3(120.0,0.0,hsi.b)),out.a);
    
    out = float4(out.r,1.0,0.0,out.a);

    
    return out;
}




float3 rgbToHsi(float3 rgb)
{
    //intesity 0-255,saturation 0-1.0,hue=0-360
    float r=rgb.r,g=rgb.g,b=rgb.b,hue,saturation,minRGB,intensity;
    intensity=(r+g+b)/3.0;
    if(r<=g&&r<=b)////////////min of RGB
    {
        minRGB=r;
    }
    else if(g<=b)
    {
        minRGB=g;
    }
    else minRGB=b;
    saturation=1.0-(minRGB)/(intensity);
    if(r==b&&r==g)
    {
        hue=0.0;
        saturation=0.0;
    }
    else
    {
        float rootover=(r-g)*(r-g)+(r-b)*(g-b);
        hue=sqrt(rootover);
        hue=((r-g)+(r-b))/(2.0*hue);
        hue=acos(hue);
        hue=hue*180.0/PI;//hue in degrees
        //  if(rootover<0.0)
        // hue=0.0;

    }
    if(isnan(hue)||isinf(hue))
    {
        // hue=0.0;
    }
    if(b>g)
    {
        hue=360.0-hue;
    }
    return float3(hue,saturation,intensity);

}
float3 hsiToRgb(float3 hsi)
{
    float hue=hsi.r,saturation=hsi.g,intensity=hsi.b,r,g,b;///differe in fragment shader *255.0
    if(hue>360.0)
    hue-=360.0;
    if(hue>=120.0&&hue<240.0)//////////new RGB values after hue conversion
    {

        hue-=120.0;
        r=intensity*(1.0-saturation);///////new rgb
        g=intensity*(1.0+( saturation*cos(hue*RADIAN)/cos((60.0-hue)*RADIAN)));
        b=3.0*intensity-(g+r);

    }
    else if (hue>=240.0&&hue<360.0)
    {
        hue-=240.0;
        g=intensity*(1.0-saturation);
        b=intensity*(1.0+( saturation*cos(hue*RADIAN)/cos((60.0-hue)*RADIAN)));
        r=3.0*intensity-(g+b);

    }
    else if(hue<=120.0)
    {

        r=intensity*(1.0+( saturation*cos(hue*RADIAN)/cos((60.0-hue)*RADIAN)));
        b=intensity*(1.0-saturation);
        g=3.0*intensity-(b+r);

    }
    else
    {
        //this else only for checking error remove after everythhing is set
        //means the hue is nan or infinity check why this happen try prevent or make color as gray equal to intensity;
        r=intensity;
        g=r;
        b=r;
    }
    return float3(r/255.0,g/255.0,b/255.0);
}
