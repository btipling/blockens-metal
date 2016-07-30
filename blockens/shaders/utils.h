
#ifndef utils_h
#define utils_h


#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4  position [[position]];
    float4  color;
};

struct VertexTextureOut {
    float4  position [[position]];
    float4  color;
    float2  textCoords;
};

#endif /* utils_h */