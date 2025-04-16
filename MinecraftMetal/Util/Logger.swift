//
//  Logger.swift
//  MinecraftMetal
//
//  Created by YiZhiMCQiu on 2025/4/16.
//

import Foundation

enum LogLevel: String {
    case debug = "DBG"
    case info = "INF"
    case warning = "WRN"
    case error = "ERR"
}

struct LogColor {
    static let reset = /*"\u{001B}[0m"*/""
    static let red = /*"\u{001B}[31m"*/""
    static let yellow = /*"\u{001B}[33m"*/""
    static let blue = /*"\u{001B}[34m"*/""
}

class Logger {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    private func log(_ level: LogLevel, message: String) {
        let timestamp = Date().formattedString()
        var logMessage = "[\(timestamp)] [\(level.rawValue)] \(name): \(message)"
        
        switch level {
        case .debug:
            logMessage = LogColor.blue + logMessage + LogColor.reset
        case .warning:
            logMessage = LogColor.yellow + logMessage + LogColor.reset
        case .error:
            logMessage = LogColor.red + logMessage + LogColor.reset
        default:
            break
        }
        
        print(logMessage)
    }
    
    func debug(_ message: String) {
        guard DebugLogs else { return }
        log(.debug, message: message)
    }
    
    func info(_ message: String) {
        log(.info, message: message)
    }
    
    func warning(_ message: String) {
        log(.warning, message: message)
    }
    
    func error(_ message: String) {
        log(.error, message: message)
    }
}

extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
}
