//
//  AppDelegate.swift
//  MinecraftMetal
//
//  Created by YiZhiMCQiu on 2025/4/16.
//

import Cocoa
import MetalKit

private let Log = Logger(name: "AppDelegate")

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let window = NSWindow(
            contentRect: WindowRect,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        TextureManager.initialize(textureLoader: MTKTextureLoader(device: MTLCreateSystemDefaultDevice()!))
        TextureManager.registerAll()

        setupWindow(window, self, GameView(frame: WindowRect))
        Log.info("Window generated.")

        if let screen = NSScreen.main?.frame {
            window.setFrameOrigin(NSPoint(
                x: screen.midX - window.frame.width / 2,
                y: screen.midY - window.frame.height / 2
            ))
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApp.terminate(nil)
    }
}
