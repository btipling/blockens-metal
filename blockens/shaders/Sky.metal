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

vertex VertexTextureOut skyVertex(uint vid [[ vertex_id ]],
                                     constant packed_float2* position  [[ buffer(0) ]],
                                     constant packed_float2* textCoords    [[ buffer(1) ]],
                                     constant SkyInfo* gridInfo [[ buffer(2) ]]) {

    VertexTextureOut outVertex;

    int positionIndex = vid % 6;
    float2 pos = position[positionIndex];
    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);
    outVertex.textCoords = textCoords[positionIndex];
    outVertex.vid = vid;
    return outVertex;
}

fragment float4 skyFragment(VertexTextureOut inFrag [[stage_in]],
        texture2d<float> skyTexture [[ texture(0) ]]) {

    if (inFrag.vid < 6) {
        float4 blue = rgbaToNormalizedGPUColors(2, 166, 214);
        return blue;
    }

    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);
    float4 result = skyTexture.sample(textureSampler, inFrag.textCoords);

    if (result[3] == 0) {
        discard_fragment();
    }

    return result;
}

float4 rgbaToNormalizedGPUColors(int r, int g, int b) {
    return float4(float(r)/255.0, float(g)/255.0, float(b)/255.0, 1.0);
}