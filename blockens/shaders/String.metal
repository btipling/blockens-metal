//
//  Character.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

struct StringInfo {
    int gridWidth;
    int gridHeight;

    float xScale;
    float yScale;

    float xPadding;
    float yPadding;

    int numBoxes;
    int numVertices;
    int numCharacters;
    int numSegments;
};

vertex VertexOut stringVertex(uint vid [[ vertex_id ]],
                                     constant packed_float2* position  [[ buffer(0) ]],
                                     constant packed_float2* boxTiles  [[ buffer(1) ]],
                                     constant packed_float2* segmentTracker  [[ buffer(2) ]],
                                     constant StringInfo* stringInfo [[ buffer(3) ]]) {

    VertexOut outVertex;

    float size = 0.04;
    float padding = 0.01;

    float2 pos = position[vid] * size;
    float diff = 2 * size;
    float offset = 2 - diff;
    float upwardMov = offset/2 - padding;
    pos[1] += upwardMov;
    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);

    return outVertex;
}

fragment float4 stringFragment(VertexTextureOut inFrag [[stage_in]]) {

    return float4(1.0, 1.0, 1.0, 1.0);
}