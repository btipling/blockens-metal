//
//  Shaders.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct GridInfo {
    uint gridDimension;
};

struct VertexOut {
    float4  position [[position]];
    float4  color;
};

vertex VertexOut passThroughVertex(uint vid [[ vertex_id ]],
                                     constant packed_float3* position  [[ buffer(0) ]],
                                     constant packed_float4* color    [[ buffer(1) ]],
                                     constant GridInfo* gridInfo [[ buffer(2) ]])
{
    VertexOut outVertex;
    float3 pos = position[vid];
    pos *= 0.5;
    outVertex.position = float4(pos[0], pos[1], pos[2], 1.0);
    outVertex.color    = color[vid];
    
    return outVertex;
};

fragment half4 passThroughFragment(VertexOut inFrag [[stage_in]])
{
    return half4(inFrag.color);
};