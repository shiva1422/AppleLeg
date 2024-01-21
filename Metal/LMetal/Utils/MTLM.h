//
//  MTLM.h
//  Metal
//
//  Created by shivaaz on 10/18/22.
//

#import<simd/simd.h>

matrix_float4x4 matrix_float4x4_translation(vector_float3 t);

matrix_float4x4 matrix_float4x4_uniform_scale(float scale);

matrix_float4x4 matrix_float4x4_rotation(vector_float3 axis, float angle);

matrix_float4x4 matrix_float4x4_perspective(float aspect, float fovy, float near, float far);
