//
//  Background.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/28/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex VertexOut backgroundVertex(uint vid [[ vertex_id ]],
                                     constant packed_float2* position  [[ buffer(0) ]],
                                     constant packed_float4* color    [[ buffer(1) ]]) {

    VertexOut outVertex;

    float2 pos = position[vid];
    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);
    outVertex.color    = float4(1.0, 1.0, 1.0, 1.0);

    return outVertex;
};

fragment half4 backgroundFragment(VertexOut inFrag [[stage_in]]) {
    return half4(inFrag.color);
};

