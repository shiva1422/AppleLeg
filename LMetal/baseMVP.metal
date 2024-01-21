//
//  Triangle.metal
//  Metal
//
// Created by shivaaz on 10/15/22.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    
float4x4 mvpMatrix;
    
};

vertex Vertex v_main(const device Vertex *vertices [[buffer(0)]],
                          uint vid [[vertex_id]])
{
    return vertices[vid];
}



fragment float4 f_main(Vertex inVertex [[stage_in]])
{
    return inVertex.color;
}


/*device and constant address space qualifiers.
 device = in general is  used when indexing into a buffer using per-vertex or per-fragment offset such as the parameter attributed with vertex_id
 constant = constant address space is used when many invocations of the function will access the same portion of the buffer, as is the case when accessing the uniform structure for every vertex.
 */
vertex Vertex v_mvp(const device Vertex *vertices [[buffer(0)]],
                    constant Uniforms *uniforms   [[buffer(1)]],
                    uint vid [[vertex_id]])
{
    Vertex vout ;
    vout.position = uniforms->mvpMatrix * vertices[vid].position;
    vout.color = vertices[vid].color;
    return vout;
    
}

fragment float4 f_flatcolor(Vertex inVertex [[stage_in]])
{
    return inVertex.color;
}
