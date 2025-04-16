//
//  matrix_float4x4.swift
//  MinecraftMetal
//
//  Created by YiZhiMCQiu on 2025/4/16.
//

import MetalKit

extension matrix_float4x4 {
    func rotate(angle: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
        let c = cos(angle)
        let s = sin(angle)
        let t = 1 - c
        let x = axis.x, y = axis.y, z = axis.z
        
        return matrix_float4x4(
            columns: (
                SIMD4<Float>(t * x * x + c,      t * x * y + z * s,  t * x * z - y * s,  0),
                SIMD4<Float>(t * x * y - z * s,  t * y * y + c,      t * y * z + x * s,  0),
                SIMD4<Float>(t * x * z + y * s,  t * y * z - x * s,  t * z * z + c,      0),
                SIMD4<Float>(0,                  0,                  0,                  1)
            )
        )
    }
}
