//
//  Logger.swift
//  Fruends (IOS)
//
//  Created by Muhammad Abbas on 02/09/2022.
//

import Foundation
import os.log

enum LogCategory: String, CaseIterable {

    case db = "DB"
    case lifecycle = "Lifecycle"
    case network = "Network"
    case push = "Push"
    case ui = "UI"
    case userContext = "UserContext"
    case xctest = "XCTest"
    case chat = "Chat"
    case profile = "Profile"
    case home = "Home"
    case permissions = "Permissions"
}

class Logger {
    init() {
        for category in LogCategory.allCases {
            categorizedLoggers[category.rawValue] = OSLog(subsystem: subsystem, category: category.rawValue)
        }
    }
    
    func fault(_ message: @autoclosure () -> String, category: LogCategory,
               fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
        guard let logger = categorizedLoggers[category.rawValue] else {
            return
        }
        
        if logger.isEnabled(type: .fault) {
            log(message(), logger: logger, logType: .fault, fileName: fileName, functionName: functionName, lineNumber: lineNumber)
        }
    }
    
    func error(_ message: @autoclosure () -> String, category: LogCategory,
               fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
        guard let logger = categorizedLoggers[category.rawValue] else {
            return
        }
        
        if logger.isEnabled(type: .error) {
            log(message(), logger: logger, logType: .error, fileName: fileName, functionName: functionName, lineNumber: lineNumber)
        }
    }
    
    func info(_ message: @autoclosure () -> String, category: LogCategory,
              fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
        guard let logger = categorizedLoggers[category.rawValue] else {
            return
        }
        
        if logger.isEnabled(type: .info) {
            log(message(), logger: logger, logType: .info, fileName: fileName, functionName: functionName, lineNumber: lineNumber)
        }
    }
    
    func debug(_ message: @autoclosure () -> String, category: LogCategory,
               fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
        guard let logger = categorizedLoggers[category.rawValue] else {
            return
        }
        
        if logger.isEnabled(type: .debug) {
            log(message(), logger: logger, logType: .debug, fileName: fileName, functionName: functionName, lineNumber: lineNumber)
        }
    }
    
    // MARK: - Private
    
    // SUBSYSTEM: "com.fryends.app"
    // CATEGORY: "Lifecycle"
    
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.fryends.app"
    private var categorizedLoggers = [String: OSLog]()
    
    private static func getCurrentThreadName() -> String {
        if Thread.isMainThread {
            return "main"
        } else {
            if let threadName = Thread.current.name, !threadName.isEmpty {
                return "\(threadName)"
                
            } else if let queueName = String(validatingUTF8: __dispatch_queue_get_label(nil)), !queueName.isEmpty {
                return "\(queueName)"
                
            } else {
                return String(format: "%p", Thread.current)
            }
        }
    }
    
    private func log(_ message: @autoclosure () -> String, logger: OSLog, logType: OSLogType,
                     fileName: String, functionName: String, lineNumber: Int) {
        let message = message()
        let currentThread = Logger.getCurrentThreadName()
        let file = (fileName as NSString).lastPathComponent
        let line = String(lineNumber)
        
        let logMessage = "[\(currentThread)] [\(file):\(line) \(functionName)] > \(message)"
        os_log("%{public}@", log: logger, type: logType, logMessage)
    }
}
