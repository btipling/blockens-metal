//
//  stars.metal
//  blockens
//
//  Created by Bjorn Tipling on 8/18/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"


vertex VertexPointOut starsVertex(uint vid [[ vertex_id ]],
                                     constant packed_float2* position  [[ buffer(0) ]],
                                     constant packed_float4* colors [[ buffer(1) ]],
                                     constant float* sizes [[ buffer(2) ]],
                                     constant float* viewDiffRatio [[ buffer(3) ]]) {

    VertexPointOut outVertex;

    float2 pos = position[vid];

    pos[1] = pushUpYByRatio(pos[1], *viewDiffRatio);

    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);
    outVertex.pointSize = sizes[vid];
    outVertex.color = colors[vid];

    return outVertex;
}

fragment float4 starsFragment(VertexPointOut inFrag [[stage_in]]) {

    return inFrag.color;
}