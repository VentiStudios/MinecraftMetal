//
//  Path.swift
//  MinecraftMetal
//
//  Created by YiZhiMCQiu on 2025/4/16.
//

import Foundation

class ResourceManager {
    public static let ResourcesBundle = loadBundle("Resources")
    
    public static func loadBundle(_ name: String, _ suffix: String = "bundle") -> Bundle {
        let bundleUrl = Bundle.main.executableURL!
            .deletingLastPathComponent()
            .appendingPathComponent("\(name).\(suffix)")
        
        guard let bundle = Bundle(url: bundleUrl) else {
            fatalError("Failed to load bundle \(bundleUrl)")
        }
        return bundle
    }
}

