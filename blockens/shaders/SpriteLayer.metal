//
//  SpriteLayer.metal
//  blockens
//
//  Created by Bjorn Tipling on 8/8/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex VertexOut spriteVertex(uint vid [[ vertex_id ]],
                            constant packed_float2* position [[ buffer(0) ]]) {

    float2 pos = position[vid];
    VertexOut outVertex;
    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);
    return outVertex;
}

fragment float4 spriteFragment(VertexTextureOut inFrag [[stage_in]]) {

    return float4(1.0, 1.0, 1.0, 1.0);
}