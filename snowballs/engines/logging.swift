//
//  logging.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import os
import OSLog
import SwiftUI


enum LogType {
    case log
    case error
}

class Logs {
    static let shared = Logs()
    
    private let coreLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Core")
    
    func core(_ message: String, _ type: LogType = .log) {
        switch type {
            case .error:
                coreLogger.error("\(message, privacy: .public)")
            default:
                coreLogger.log("\(message, privacy: .public)")
        }
    }
    
    
    private func fetchLogsSinceBoot() -> [OSLogEntryLog] {
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let position = store.position(timeIntervalSinceLatestBoot: 1)
            let entries = try store
                .getEntries(at: position)
                .compactMap { $0 as? OSLogEntryLog }
                .filter { $0.subsystem == Bundle.main.bundleIdentifier! }
            return entries
        } catch {
            coreLogger.warning("failed to fetch logs: \(error.localizedDescription)")
        }
        return []
    }
    
    @MainActor
    func logsAsCSV() async {
        let logs = self.fetchLogsSinceBoot()
        var csvString = "timestamp, category, message\n"
        for log in logs {
            let dataString = "\"\(log.date.formatted())\", \"\(log.category)\",\"\(log.composedMessage)\"\n"
            csvString = csvString.appending(dataString)
        }

        do {
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.isExtensionHidden = false
            savePanel.allowsOtherFileTypes = false
            savePanel.title = "Save the log file"
            savePanel.message = "Choose a folder where to save the log file"
            savePanel.prompt = "Save"
            savePanel.nameFieldLabel = "File name:"
            savePanel.nameFieldStringValue = "Snowballs Logs - \(Date().formatted(.iso8601)).csv"
           
            let response = savePanel.runModal()
            guard response == .OK, let saveURL = savePanel.url else { return }
            try csvString.write(to: saveURL, atomically: true, encoding: .utf8)
        } catch {
            Logs.shared.core("Failed to create the logs .CSV file: \(error.localizedDescription)", .error)
        }
    }
}
