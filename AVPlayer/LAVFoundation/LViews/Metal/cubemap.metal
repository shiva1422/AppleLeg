//
//  Triangle.metal
//  Metal
//
//Created by shivaaz on 10/15/22.
//

#include <metal_stdlib>
using namespace metal;

#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[attribute(0)]];
    float4 normal [[attribute(1)]];
};

struct OutVertex
{
    float4 position [[position]];//because vertex shader must output with attribute position
    float4 uvCoods;
};

struct Uniforms {
    
float4x4 mvpMatrix;
    
};

vertex OutVertex vert(Vertex vertices [[stage_in]],
                    constant Uniforms &uniforms   [[buffer(1)]],
                    uint vid [[vertex_id]])
{
    //position is like _glPosition
    float4 position = uniforms.mvpMatrix * vertices.position;//if attrib in Vertex,then position
    OutVertex vout;
    vout.position = position;
    vout.uvCoods = vout.position;//position.
    return vout;
    
}

fragment float4 frag(OutVertex vert [[stage_in]] ,texturecube<float> cubeTexture [[texture(0)]],sampler cubeSampler [[sampler(0)]])
{
    float3 texCoords = float3(vert.uvCoods.x, vert.uvCoods.y, -vert.uvCoods.z);//invert z because cube is lefthanded by we want right
    //return float4(1.0,0.0,0.0,1.0);
    return cubeTexture.sample(cubeSampler, texCoords);
}


/*
 xcrun -sdk iphonesimulator metal -c shaders/cubemap.metal -o ./cubemap.air
 xcrun -sdk iphonesimulator metallib ./cubemap.air -o metallib/cubemap.metallib
 rm cubemap.air


 */
