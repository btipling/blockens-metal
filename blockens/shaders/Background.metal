//
//  Background.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/28/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex VertexTextureOut backgroundVertex(uint vid [[ vertex_id ]],
                                     constant packed_float2* position  [[ buffer(0) ]],
                                     constant packed_float4* color    [[ buffer(1) ]],
                                     constant packed_float2* textCoords  [[ buffer(2) ]]) {

    VertexTextureOut outVertex;

    float2 pos = position[vid];
    outVertex.position = float4(pos[0], pos[1], 1.0, 1.0);
    outVertex.color    = color[0];
    outVertex.textCoords = textCoords[vid];

    return outVertex;
};

fragment float4 backgroundFragment(VertexTextureOut inFrag [[stage_in]],
        texture2d<float> bgTexture [[ texture(0) ]]) {
    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);
    float2 coords = inFrag.textCoords * 5;
    return bgTexture.sample(textureSampler, coords);
};

