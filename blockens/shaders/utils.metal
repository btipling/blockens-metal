
#include "utils.h"

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

float4 rgbaToNormalizedGPUColors(int r, int g, int b) {
    return float4(float(r)/255.0, float(g)/255.0, float(b)/255.0, 1.0);
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