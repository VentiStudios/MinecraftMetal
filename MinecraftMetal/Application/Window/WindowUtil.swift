//
//  WindowUtil.swift
//  MinecraftMetal
//
//  Created by YiZhiMCQiu on 2025/4/16.
//

import Foundation
import Cocoa

func setupWindow(_ window: NSWindow, _ delegate: AppDelegate, _ view: GameView) {
    window.title = "Minecraft Metal"
    window.delegate = delegate
    window.level = .normal
    window.contentView = view
    window.makeKeyAndOrderFront(nil)
    
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
}
