//
//  GameView.swift
//  MinecraftMetal
//
//  Created by YiZhiMCQiu on 2025/4/16.
//

import MetalKit

class GameView: MTKView {
    var renderer: MetalRenderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.device = MTLCreateSystemDefaultDevice()
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device ?? MTLCreateSystemDefaultDevice())
        self.renderer = MetalRenderer(metalView: self)
        self.delegate = renderer
        self.framebufferOnly = false
        self.enableSetNeedsDisplay = false
        self.isPaused = false
    }
}
