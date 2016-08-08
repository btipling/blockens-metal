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

    float scale;

    float xPadding;
    float yPadding;

    int numBoxes;
    int numVertices;
    int numCharacters;
    int numSegments;
};

vertex VertexOut stringVertex(uint vid [[ vertex_id ]],
                                     constant packed_float2* position  [[ buffer(0) ]],
                                     constant int* segmentPositions  [[ buffer(1) ]],
                                     constant int* segmentsPerCharacter  [[ buffer(2) ]],
                                     constant StringInfo* stringInfo [[ buffer(3) ]]) {

    VertexOut outVertex;

    uint vertexId = vid % 6;
    int currentSegment = (int)(vid / 6);

    // Scale the character from normal coordinates.
    float2 pos = position[vertexId];

    // Position segment vertex within character grid.
    int segmentPosition = segmentPositions[currentSegment];

    float col = segmentPosition % stringInfo->gridWidth;
    float row = (stringInfo->gridHeight - 1) - segmentPosition / stringInfo->gridWidth;

    float2 orgPosition = float2(pos[0], pos[1]);

    pos[0] /= stringInfo->gridWidth;
    pos[1] /= stringInfo->gridHeight;

    // Translate box to bottom right (-1, -1) position.
    pos[0] -= fabs(orgPosition[0]) - fabs(pos[0]);
    pos[1] -= fabs(orgPosition[1]) - fabs(pos[1]);

    // Translate box to its colum and row position from bottom right.
    pos[0] += float((2.0/stringInfo->gridWidth) * col);
    pos[1] += float((2.0/stringInfo->gridHeight) * row);


    // Offset to character x position.
    int currentChar = 0;
    for( int i = 0; i < stringInfo->numCharacters; i++ ) {
        int segmentCount = segmentsPerCharacter[i];
        if (currentSegment >= segmentCount) {
             currentChar += 1;
        } else {
            break;
        }
    }
    pos[0] += currentChar * 2.5;

    pos *= stringInfo->scale;
    float diff = 2 * stringInfo->scale;
    float offset = (2 - diff)/2;

    // Set padding from top left.
    pos[0] -= offset;
    pos[0] += stringInfo->xPadding;
    pos[1] += offset - stringInfo->yPadding;



    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);
    return outVertex;
}

fragment float4 stringFragment(VertexTextureOut inFrag [[stage_in]]) {

    return float4(1.0, 1.0, 1.0, 1.0);
}