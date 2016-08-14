
#include "utils.h"

float4 rgbaToNormalizedGPUColors(int r, int g, int b) {
    return float4(float(r)/255.0, float(g)/255.0, float(b)/255.0, 1.0);
}

GridPosition gridPosFromArrayLocation(int arrayIndex, int gridWidth) {

    GridPosition gridPosition;
    gridPosition.col = arrayIndex % gridWidth;
    gridPosition.row = arrayIndex / gridWidth;

    return gridPosition;
}

GridPosition flipGridVertically(GridPosition gridPos, int gridHeight) {
    gridPos.row = (gridHeight - 1) - gridPos.row;
    return gridPos;
}

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

float pushUpYByRatio(float y, float viewDiffRatio) {
    float result = y * viewDiffRatio;
    float offset = 2 * viewDiffRatio;
    result += (2 - offset)/2;
    return result;
}

float2 moveToGridPosition(float2 orgPosition, int col, int row, float gridWidth, float gridHeight) {

    float2 pos = float2(orgPosition[0], orgPosition[1]);

    // Shrink box to grid cell size.
    pos[0] /= gridWidth;
    pos[1] /= gridHeight;

    // Translate box to bottom right (-1, -1) position.
    pos[0] -= fabs(orgPosition[0]) - fabs(pos[0]);
    pos[1] -= fabs(orgPosition[1]) - fabs(pos[1]);

    // Translate box to its column and row position from bottom right.
    pos[0] += float((2.0/gridWidth) * col);
    pos[1] += float((2.0/gridHeight) * row);

    return pos;
}

float getCoordinateForDimension(float textCoord, float dimensionSize, float spritePos) {
    float spriteSize = 1.0 / dimensionSize;
    float start = spriteSize * spritePos;
    float pos = textCoord;
    return start + spriteSize * pos;
}

float2 textureCoordinatesForSprite(float2 spritePos, float2 textCoords, SpriteLayerInfo spriteLayerInfo) {

    textCoords[0] = getCoordinateForDimension(textCoords[0], spriteLayerInfo.textureWidth, spritePos[0]);
    textCoords[1] = getCoordinateForDimension(textCoords[1], spriteLayerInfo.textureHeight, spritePos[1]);

    return textCoords;
}