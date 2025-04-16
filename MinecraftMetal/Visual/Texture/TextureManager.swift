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
    private static let missingno = registerTexture(Identifier.of("missingno"), Identifier.of("misc/missingno"))!
    
    @discardableResult
    public static func registerTexture(_ id: Identifier, _ path: Identifier? = nil) -> MTLTexture? {
        var pathIdentifier: Identifier = id
        if path != nil {
            pathIdentifier = path!
        }
        
        let textureUrl = ResourceManager.ResourcesBundle.resourceURL!.appendingPathComponent("assets/\(pathIdentifier.parent)/textures/\(pathIdentifier.path).png")
        print(textureUrl)
        
        guard let textureLoader = TextureManager.textureLoader else {
            Log.error("Failed to load texture (Not initialized)")
            return nil
        }
        do {
            textures[id] = try textureLoader.newTexture(URL: textureUrl)
        } catch {
            Log.error("Failed to load texture \(id) (\(error))")
        }
        return textures[id]
    }
    
    public static func getTexture(_ id: Identifier) -> MTLTexture {
        guard let texture = textures[id] else {
            return missingno
        }
        return texture
    }
    
    public static func initialize(textureLoader loader: MTKTextureLoader) {
        textureLoader = loader
    }
    
    public static func registerAll() {
        print(Bundle.main.executableURL!)
        registerTexture(Identifier.of("dirt"), Identifier.of("block/dirt"))
        
        registered = false
    }
}
