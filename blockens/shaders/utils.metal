
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