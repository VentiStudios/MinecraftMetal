//
//  Path.swift
//  MinecraftMetal
//
//  Created by YiZhiMCQiu on 2025/4/16.
//

import Foundation

class ResourceManager {
    public static func loadBundle(_ name: String, _ suffix: String = ".bundle") -> Bundle {
        guard let bundle = Bundle(url: Bundle.main.executableURL!
            .deletingLastPathComponent()
            .appendingPathComponent("\(name).\(suffix)")) else {
            fatalError("Failed to load bundle \(name).\(suffix)")
        }
        return bundle
    }
}
