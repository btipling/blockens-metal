//
//  Snake.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

struct SkyInfo {

};


vertex VertexOut skyVertex(uint vid [[ vertex_id ]],
                                     constant packed_float2* position  [[ buffer(0) ]],
                                     constant packed_float2* textCoords    [[ buffer(1) ]],
                                     constant SkyInfo* gridInfo [[ buffer(2) ]]) {

    VertexOut outVertex;

    return outVertex;
};

fragment float4 skyFragment(VertexOut inFrag [[stage_in]],
        texture2d<float> snakeTexture [[ texture(0) ]]) {


    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);
    float4 result = snakeTexture.sample(textureSampler, inFrag.textCoords);

    return result;
};