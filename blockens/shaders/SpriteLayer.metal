//
//  SpriteLayer.metal
//  blockens
//
//  Created by Bjorn Tipling on 8/8/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex VertexTextureOut spriteVertex(uint vid [[ vertex_id ]],
                            constant packed_float2* position [[ buffer(0) ]],
                            constant int* gridPositions [[ buffer(1) ]],
                            constant packed_float2* spritePos [[ buffer(2) ]],
                            constant packed_float2* textCoords [[ buffer(3) ]],
                            constant SpriteLayerInfo* spriteLayerInfo [[ buffer(4) ]]) {

    uint numVerticesInARectangle = 6;

    uint arrayIndex = vid / numVerticesInARectangle;
    uint vertexIndex = vid % numVerticesInARectangle;

    float2 pos = position[vertexIndex];

    VertexTextureOut outVertex;

    GridPosition gridPos = gridPosFromArrayLocation(gridPositions[arrayIndex], spriteLayerInfo->gridWidth);
    gridPos = flipGridVertically(gridPos, spriteLayerInfo->gridHeight);

    pos = moveToGridPosition(pos, gridPos.col, gridPos.row, spriteLayerInfo->gridWidth, spriteLayerInfo->gridHeight);

    pos[1] = pushDownYByRatio(pos[1], spriteLayerInfo->viewDiffRatio);

    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);
    outVertex.textCoords = textureCoordinatesForSprite(spritePos[arrayIndex], textCoords[vertexIndex], *spriteLayerInfo);

    return outVertex;
}

float2 textureCoordinatesForSprite(float2 spritePos, float2 textCoords, SpriteLayerInfo spriteLayerInfo) {

    float spriteWidth = 1.0 / spriteLayerInfo.textureWidth;
    float start = spriteWidth * spritePos[0];
    float y = textCoords[0];
    textCoords[0] = start + spriteWidth * y;
    return textCoords;
}

fragment float4 spriteFragment(VertexTextureOut inFrag [[stage_in]],
        texture2d<float> spriteTexture [[ texture(0) ]]) {

    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);

    float4 result = spriteTexture.sample(textureSampler, inFrag.textCoords);

    if (result[3] == 0) {
        discard_fragment();
    }

    return result;

}