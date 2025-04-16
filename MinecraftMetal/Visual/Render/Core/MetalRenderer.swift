import MetalKit

class MetalRenderer: NSObject, MTKViewDelegate {
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var texture: MTLTexture!
    private var rotation: Float = 0.0
    private var textureId: Identifier!

    init(mtkView: MTKView, textureId: Identifier) {
        super.init()
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device.")
        }
        self.device = device
        self.textureId = textureId
        mtkView.device = device
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.delegate = self

        setupMetal()
        setupBuffers()
        loadTexture()
    }

    private func setupMetal() {
        commandQueue = device.makeCommandQueue()

        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentShader")

        // Create a vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3 // Position (x, y, z)
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        vertexDescriptor.attributes[1].format = .float2 // Texture coordinates (u, v)
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 3
        vertexDescriptor.attributes[1].bufferIndex = 0

        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 5
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor = vertexDescriptor // Set the vertex descriptor

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    private func setupBuffers() {
        let scale: Float = 0.5

        let vertices: [Float] = [
             1 * scale,  1 * scale, -1 * scale,  1, 0,
            -1 * scale,  1 * scale, -1 * scale,  0, 0,
            -1 * scale, -1 * scale, -1 * scale,  0, 1,
             1 * scale, -1 * scale, -1 * scale,  1, 1,
            
             1 * scale,  1 * scale,  1 * scale,  0, 0,
            -1 * scale,  1 * scale,  1 * scale,  1, 0,
            -1 * scale, -1 * scale,  1 * scale,  1, 1,
             1 * scale, -1 * scale,  1 * scale,  0, 1,
            
             1 * scale,  1 * scale,  1 * scale,  1, 0,
            -1 * scale,  1 * scale,  1 * scale,  0, 0,
            -1 * scale,  1 * scale, -1 * scale,  0, 1,
             1 * scale,  1 * scale, -1 * scale,  1, 1,
            
             1 * scale, -1 * scale,  1 * scale,  1, 1,
            -1 * scale, -1 * scale,  1 * scale,  0, 1,
            -1 * scale, -1 * scale, -1 * scale,  0, 0,
             1 * scale, -1 * scale, -1 * scale,  1, 0,
            
             1 * scale,  1 * scale,  1 * scale,  1, 0,
             1 * scale, -1 * scale,  1 * scale,  1, 1,
             1 * scale, -1 * scale, -1 * scale,  0, 1,
             1 * scale,  1 * scale, -1 * scale,  0, 0,
            
            -1 * scale,  1 * scale,  1 * scale,  0, 0,
            -1 * scale, -1 * scale,  1 * scale,  0, 1,
            -1 * scale, -1 * scale, -1 * scale,  1, 1,
            -1 * scale,  1 * scale, -1 * scale,  1, 0,
        ]

        let indices: [UInt16] = [
            0, 1, 2, 2, 3, 0,
            4, 5, 6, 6, 7, 4,
            8, 9, 10, 10, 11, 8,
            12, 13, 14, 14, 15, 12,
            16, 17, 18, 18, 19, 16,
            20, 21, 22, 22, 23, 20,
        ]

        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
    }

    private func loadTexture() {
        texture = TextureManager.getTexture(textureId!)
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()!

        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(texture, index: 0)

        var modelMatrix = matrix_identity_float4x4
        rotation += 0.02
        modelMatrix = matrix_multiply(modelMatrix, matrix4x4_rotation(radians: rotation, axis: SIMD3<Float>(0, 1, 0)))

        let viewMatrix = matrix4x4_translation(0, 0, -5) // 摄像机向后移动 5 个单位
        let projectionMatrix = makePerspectiveMatrix(aspectRatio: Float(view.drawableSize.width / view.drawableSize.height),
                                                     fieldOfView: .pi / 4, // 45 度视角
                                                     near: 0.1,
                                                     far: 100)

        var modelViewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix))
        renderEncoder.setVertexBytes(&modelViewProjectionMatrix, length: MemoryLayout<matrix_float4x4>.size, index: 1)

        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: 36, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    private func makePerspectiveMatrix(aspectRatio: Float, fieldOfView: Float, near: Float, far: Float) -> matrix_float4x4 {
        let yScale = 1 / tan(fieldOfView * 0.5)
        let xScale = yScale / aspectRatio
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let wzScale = -2 * far * near / zRange

        return matrix_float4x4(columns: (
            SIMD4<Float>(xScale, 0, 0, 0),
            SIMD4<Float>(0, yScale, 0, 0),
            SIMD4<Float>(0, 0, zScale, -1),
            SIMD4<Float>(0, 0, wzScale, 0)
        ))
    }

    private func matrix4x4_rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
        var matrix = matrix_identity_float4x4
        let c = cos(radians)
        let s = sin(radians)
        let ci = 1 - c

        matrix.columns.0 = SIMD4<Float>( c + axis.x * axis.x * ci,
                                         axis.y * axis.x * ci + axis.z * s,
                                         axis.z * axis.x * ci - axis.y * s,
                                         0)
        matrix.columns.1 = SIMD4<Float>( axis.x * axis.y * ci - axis.z * s,
                                         c + axis.y * axis.y * ci,
                                         axis.z * axis.y * ci + axis.x * s,
                                         0)
        matrix.columns.2 = SIMD4<Float>( axis.x * axis.z * ci + axis.y * s,
                                         axis.y * axis.z * ci - axis.x * s,
                                         c + axis.z * axis.z * ci,
                                         0)
        matrix.columns.3 = SIMD4<Float>( 0, 0, 0, 1)

        return matrix
    }

    private func matrix4x4_translation(_ x: Float, _ y: Float, _ z: Float) -> matrix_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.3 = SIMD4<Float>(x, y, z, 1)
        return matrix
    }
}
