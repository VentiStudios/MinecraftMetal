#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(VertexIn in [[stage_in]],
                              constant float4x4 &modelViewProjectionMatrix [[buffer(1)]]) {
    VertexOut out;
    out.position = modelViewProjectionMatrix * float4(in.position, 1.0);
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> texture [[texture(0)]]) {
    constexpr sampler textureSampler(address::repeat, filter::nearest);
    return texture.sample(textureSampler, in.texCoord);
}