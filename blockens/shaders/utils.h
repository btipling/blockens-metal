
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
};

#endif /* utils_h */