//
//  Shaders.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct GridInfo {
    int gridDimension;
    float gridOffset;
    int numBoxes;
    int numVertices;
    int numColors;
};

struct VertexOut {
    float4  position [[position]];
    float4  color;
};

vertex VertexOut passThroughVertex(uint vid [[ vertex_id ]],
                                     constant packed_float2* position  [[ buffer(0) ]],
                                     constant packed_float4* color    [[ buffer(1) ]],
                                     constant GridInfo* gridInfo [[ buffer(2) ]],
                                     constant int* gameTiles [[ buffer(3) ]])
{

    VertexOut outVertex;

    int dimension = gridInfo->gridDimension;
    int numVertices = gridInfo->numVertices;
    int boxNum = vid / numVertices;
    int positionIndex = vid % numVertices;
    int col = boxNum % dimension;
    int row = boxNum / dimension;

    float2 pos = position[positionIndex];
    float2 orgPosition = float2(pos[0], pos[1]);

    // Scale box size based on dimension where dimension is the width and height as both are the same value.
    pos /= dimension;

    // Translate box to bottom right (-1, -1) position.
    pos[0] -= fabs(orgPosition[0]) - fabs(pos[0]);
    pos[1] -= fabs(orgPosition[1]) - fabs(pos[1]);

    // Translate box to its colum and row position from bottom right.
    pos[0] += gridInfo->gridOffset * float(col);
    pos[1] += gridInfo->gridOffset * float(row);

    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);

    if (gameTiles[boxNum] < 10) {
        outVertex.color = color[0];
    } else {
        outVertex.color = color[1];
    }
    
    return outVertex;
};

fragment half4 passThroughFragment(VertexOut inFrag [[stage_in]])
{
    return half4(inFrag.color);
};