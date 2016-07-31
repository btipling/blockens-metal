//
//  Background.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/28/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex VertexTextureOut backgroundVertex(uint vid [[ vertex_id ]],
                                     constant int* tickCount [[ buffer(0) ]],
                                     constant packed_float2* position  [[ buffer(1) ]],
                                     constant packed_float2* textCoords  [[ buffer(2) ]]) {

    VertexTextureOut outVertex;

    float2 pos = position[vid];
    outVertex.position = float4(pos[0], pos[1], 1.0, 1.0);
    outVertex.tickCount = tickCount[0];
    outVertex.textCoords = textCoords[vid];

    return outVertex;
};

fragment float4 backgroundFragment(VertexTextureOut inFrag [[stage_in]],
        texture2d<float> bgTexture1 [[ texture(0) ]],
        texture2d<float> bgTexture2 [[ texture(1) ]],
        texture2d<float> bgTexture3 [[ texture(2) ]],
        texture2d<float> bgTexture4 [[ texture(3) ]],
        texture2d<float> bgTexture5 [[ texture(4) ]]) {

    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);
    float2 coords = inFrag.textCoords * 6;

    switch (inFrag.tickCount % 5) {
        case 0:
            return bgTexture1.sample(textureSampler, coords);
        case 1:
            return bgTexture2.sample(textureSampler, coords);
        case 2:
            return bgTexture3.sample(textureSampler, coords);
        case 3:
            return bgTexture4.sample(textureSampler, coords);
        default:
            return bgTexture5.sample(textureSampler, coords);
    }

};

