//
//  SpriteLayer.metal
//  blockens
//
//  Created by Bjorn Tipling on 8/8/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"


struct SpriteLayerInfo {
    int gridWidth;
    int gridHeight;
    float viewDiffRatio;
    int numVertices;
};

vertex VertexTextureOut spriteVertex(uint vid [[ vertex_id ]],
                            constant packed_float2* position [[ buffer(0) ]],
                            constant packed_float2* textCoords [[ buffer(1) ]],
                            constant int* gridPositions [[ buffer(2) ]],
                            constant SpriteLayerInfo* spriteLayerInfo [[ buffer(3) ]]) {

    float2 pos = position[vid];
    VertexTextureOut outVertex;

    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);
    outVertex.textCoords = textCoords[vid];

    return outVertex;
}

fragment float4 spriteFragment(VertexTextureOut inFrag [[stage_in]],
        texture2d<float> spriteTexture [[ texture(0) ]]) {

    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);

    float2 coords = inFrag.textCoords;
    float4 result = spriteTexture.sample(textureSampler, coords);

    if (result[3] == 0) {
        discard_fragment();
    }

    return result;

}