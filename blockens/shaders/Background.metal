//
//  Background.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/28/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

struct BGInfo {
    int tickCount;
    float viewDiffRatio;
};

vertex VertexTextureOut backgroundVertex(uint vid [[ vertex_id ]],
                                     constant BGInfo* bgInfo [[ buffer(0) ]],
                                     constant packed_float2* position  [[ buffer(1) ]],
                                     constant packed_float2* textCoords  [[ buffer(2) ]]) {

    VertexTextureOut outVertex;

    float2 pos = position[vid % 6];

    if (vid >= 6) {
        pos[1] = pushDownYByRatio(pos[1], bgInfo->viewDiffRatio);
    }

    outVertex.position = float4(pos[0], pos[1], 1.0, 1.0);
    outVertex.tickCount = bgInfo->tickCount;
    outVertex.textCoords = textCoords[vid % 6];
    outVertex.vid = vid;

    return outVertex;
};

fragment float4 backgroundFragment(VertexTextureOut inFrag [[stage_in]],
        texture2d<float> bgTexture1 [[ texture(0) ]],
        texture2d<float> bgTexture2 [[ texture(1) ]],
        texture2d<float> bgTexture3 [[ texture(2) ]],
        texture2d<float> bgTexture4 [[ texture(3) ]],
        texture2d<float> bgTexture5 [[ texture(4) ]]) {

    if (inFrag.vid < 6) {
        float4 blue = rgbaToNormalizedGPUColors(2, 166, 214);
        return blue;
    }

    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);
    float2 coords = inFrag.textCoords * 3;

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

float pushDownYByRatio(float y, float viewDiffRatio) {
    y -= 1;
    y *= -1;
    float yRatio = y/2;
    float missingHeight = 2 * viewDiffRatio;
    float newHeight = 2 - missingHeight;
    float newTop = missingHeight - 1;
    float result = (newHeight * yRatio) + newTop;
    result *= -1;
    return result;
}

float4 rgbaToNormalizedGPUColors(int r, int g, int b) {
    return float4(float(r)/255.0, float(g)/255.0, float(b)/255.0, 1.0);
}
