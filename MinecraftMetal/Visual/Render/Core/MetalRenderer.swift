import MetalKit

struct Vertex {
    var position: SIMD3<Float>  // 对应Metal中的float3
    var color: SIMD4<Float>     // 对应Metal中的float4
}

class MetalRenderer: NSObject, MTKViewDelegate {
    // MARK: - 核心对象
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var rotationAngle: Float = 0
    
    // MARK: - 初始化
    init(metalView: MTKView) {
        super.init()
        setupMetal(with: metalView)
        setupPipeline()
        setupVertexBuffer()
    }
    
    private func setupMetal(with view: MTKView) {
        device = view.device ?? MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        view.delegate = self
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    // MARK: - 渲染管线配置
    private func setupPipeline() {
        guard let library = device.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "vertexShader"),
              let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
            fatalError("无法加载着色器")
        }
        
        // 顶点描述符（匹配Shader中的结构体）
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3 // position
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4 // color
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("管线创建失败: \(error)")
        }
    }
    
    // MARK: - 立方体顶点数据
    private func setupVertexBuffer() {
        struct Vertex {
            var position: SIMD3<Float>
            var color: SIMD4<Float>
        }
        
        let vertices: [Vertex] = [
            // 前面 (z=0.5)
            Vertex(position: [-0.5, -0.5,  0.5], color: [1, 0, 0, 1]),
            Vertex(position: [ 0.5, -0.5,  0.5], color: [0, 1, 0, 1]),
            Vertex(position: [ 0.5,  0.5,  0.5], color: [0, 0, 1, 1]),
            Vertex(position: [-0.5,  0.5,  0.5], color: [1, 1, 0, 1]),
            
            // 后面 (z=-0.5)
            Vertex(position: [-0.5, -0.5, -0.5], color: [1, 0, 1, 1]),
            Vertex(position: [ 0.5, -0.5, -0.5], color: [0, 1, 1, 1]),
            Vertex(position: [ 0.5,  0.5, -0.5], color: [1, 1, 1, 1]),
            Vertex(position: [-0.5,  0.5, -0.5], color: [0, 0, 0, 1])
        ]
        
        // 立方体索引（36个顶点 = 6面×2三角形×3顶点）
        let indices: [UInt16] = [
            // 前面
            0, 1, 2, 2, 3, 0,
            // 右面
            1, 5, 6, 6, 2, 1,
            // 后面
            7, 6, 5, 5, 4, 7,
            // 左面
            4, 0, 3, 3, 7, 4,
            // 顶面
            3, 2, 6, 6, 7, 3,
            // 底面
            4, 5, 1, 1, 0, 4
        ]
        
        // 创建顶点+索引缓冲区
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: []
        )
    }
    
    // MARK: - 渲染循环
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPass = view.currentRenderPassDescriptor else { return }
        
        rotationAngle += 0.01
        
        // 创建命令缓冲区
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass)!
        
        // 设置管线状态
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // 传递顶点数据
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // 计算模型矩阵（旋转+透视）
        var modelMatrix = matrix_float4x4()
        modelMatrix.translate(0, 0, -3) // 移远
        modelMatrix.rotate(angle: rotationAngle, axis: [1, 1, 0]) // 绕对角线旋转
        renderEncoder.setVertexBytes(&modelMatrix, length: MemoryLayout<matrix_float4x4>.size, index: 1)
        
        // 绘制立方体（36个顶点）
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 36)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - 矩阵扩展
extension matrix_float4x4 {
    mutating func translate(_ x: Float, _ y: Float, _ z: Float) {
        self.columns.3 = [x, y, z, 1]
    }
    
    mutating func rotate(angle: Float, axis: SIMD3<Float>) {
        let c = cos(angle)
        let s = sin(angle)
        let t = 1 - c
        let x = axis.x, y = axis.y, z = axis.z
        
        self = matrix_multiply(self, matrix_float4x4(
            columns: (
                [t*x*x + c,   t*x*y + z*s, t*x*z - y*s, 0],
                [t*x*y - z*s, t*y*y + c,   t*y*z + x*s, 0],
                [t*x*z + y*s, t*y*z - x*s, t*z*z + c,   0],
                [0,           0,           0,           1]
            )
        ))
    }
}
