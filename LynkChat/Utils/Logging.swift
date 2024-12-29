//
//  Logging.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import Foundation
import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    private static let baseLogger = Logger(subsystem: subsystem, category: "api")
    
    static func info(_ message: String) {
        guard AppConfig.shared.printDebgLogs else { return }
        baseLogger.info("\(message)")
    }
    
    static func notice(_ message: String) {
        guard AppConfig.shared.printDebgLogs else { return }
        baseLogger.notice("\(message)")
    }
    
    static func trace(_ message: String) {
        guard AppConfig.shared.printDebgLogs else { return }
        baseLogger.trace("\(message)")
    }
    
    static func debug(_ message: String) {
        guard AppConfig.shared.printDebgLogs else { return }
        baseLogger.debug("\(message)")
    }
    
    static func error(_ message: String) {
        guard AppConfig.shared.printDebgLogs else { return }
        baseLogger.error("\(message)")
    }
    
    static func warning(_ message: String) {
        guard AppConfig.shared.printDebgLogs else { return }
        baseLogger.warning("\(message)")
    }
    
    static func log(level: OSLogType, _ message: String) {
        guard AppConfig.shared.printDebgLogs else { return }
        baseLogger.log(level: level, "\(message)")
    }
}
