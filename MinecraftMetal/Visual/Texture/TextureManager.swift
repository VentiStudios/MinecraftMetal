//
//  TextureManager.swift
//  MinecraftMetal
//
//  Created by YiZhiMCQiu on 2025/4/16.
//

import MetalKit

private let Log = Logger(name: "TextureManager")

class TextureManager {
    private static var registered: Bool = true
    private static var textures: [Identifier : MTLTexture] = [:];
    private static var textureLoader: MTKTextureLoader? = nil
    
    public static func registerTexture(_ id: Identifier, _ textureUrl: URL!) {
        guard let url = textureUrl else {
            Log.error("Failed to load texture \(id) (No such file)")
            return
        }
        guard let textureLoader = TextureManager.textureLoader else {
            Log.error("Failed to load texture (Not initialized)")
            return
        }
        do {
            textures[id] = try textureLoader.newTexture(URL: textureUrl)
        } catch {
            Log.error("Failed to load texture \(id) (\(error))")
        }
    }
    
    public static func getTexture(_ id: Identifier) -> MTLTexture? {
        return textures[id]
    }
    
    public static func initialize(textureLoader loader: MTKTextureLoader) {
        textureLoader = loader
    }
    
    public static func registerAll() {
        registerTexture(Identifier.of("dirt"), URL(fileURLWithPath: "/Users/yizhimcqiu/Documents/MinecraftMetal/Resources/dirt.png"))
        
        registered = false
    }
}
