//
//  Snake.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

struct GridInfo {
    int gridDimension;
    int numBoxes;
    int numVertices;
    float viewDiffRatio;
};

enum GameTile {

    HeadUp, HeadDown, HeadLeft, HeadRight,
    TailUp, TailDown, TailLeft, TailRight,
    BodyHorizontal, BodyVertical,
    CornerUpLeft, CornerUpRight, CornerDownLeft, CornerDownRight,

    EmptyTile, GrowTile,

};

vertex VertexOut gameTileVertex(uint vid [[ vertex_id ]],
                                     constant packed_float2* position  [[ buffer(0) ]],
                                     constant packed_float2* textCoords    [[ buffer(1) ]],
                                     constant GridInfo* gridInfo [[ buffer(2) ]],
                                     constant int* gameTiles [[ buffer(3) ]],
                                     constant int* boxTiles [[ buffer(4) ]]) {

    VertexOut outVertex;

    int dimension = gridInfo->gridDimension;
    int numVertices = gridInfo->numVertices;

    int tileNum = vid / numVertices;
    int positionIndex = vid % numVertices;

    int gameTile = gameTiles[tileNum];
    int boxNum = boxTiles[tileNum];

    GridPosition gridPos = gridPosFromArrayLocation(boxNum, dimension);

    float2 pos = position[positionIndex];
    float2 coords = textCoords[positionIndex];

    pos = moveToGridPosition(pos, gridPos.col, gridPos.row, dimension, dimension);

    pos[1] = pushDownYByRatio(pos[1], gridInfo->viewDiffRatio);

    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);
    outVertex.textCoords = coords;

    if (gameTile < EmptyTile) {
        outVertex.textureId = 0;
    } else {
        outVertex.textureId = 1;
    }
    
    return outVertex;
}

fragment float4 gameTileFragment(VertexOut inFrag [[stage_in]],
        texture2d<float> snakeTexture [[ texture(0) ]],
        texture2d<float> foodTexture [[ texture(1) ]]) {


    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);
    float2 coords = inFrag.textCoords;
    float4 result;
    switch (inFrag.textureId) {
        case 0:
            result = snakeTexture.sample(textureSampler, coords);
            break;
        default:
            result = foodTexture.sample(textureSampler, coords);
            break;
    }
    if (result[3] == 0) {
        discard_fragment();
    }
    return result;
}