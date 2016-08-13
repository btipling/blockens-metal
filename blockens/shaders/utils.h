
#ifndef utils_h
#define utils_h


#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4  position [[position]];
    int  textureId;
    float2  textCoords;
};

struct VertexTextureOut {
    float4  position [[position]];
    int  tickCount;
    float2  textCoords;
    uint vid;
};

struct SpriteLayerInfo {
    int gridWidth;
    int gridHeight;
    int textureWidth;
    int textureHeight;
    float viewDiffRatio;
    int numVertices;
};


float pushDownYByRatio(float y, float viewDiffRatio);
float pushUpYByRatio(float y, float viewDiffRatio);
float4 rgbaToNormalizedGPUColors(int r, int g, int b);
float2 textureCoordinatesForSprite(float2 spriteCol, float2 textCoords, SpriteLayerInfo spriteLayerInfo);

#endif /* utils_h */