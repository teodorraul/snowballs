//
//  App.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import SwiftUI

@main
struct SnowballsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
      AppDelegate.shared = self.appDelegate
    }

    var body: some Scene {
        MenuBarExtra {
            Button("Configure") {
                WindowsStore.shared.showConfigureWindow()
            }
            Button("Adjust Hotkeys") {
                WindowsStore.shared.showAdjustHotkeysWindow()
            }
            Button("Contribute / Bugs / Requests") {
                if let url = URL(string: "https://github.com/teodorraul/snowballs") {
                    NSWorkspace.shared.open(url)
                }
            }
            Divider()
            Button("Export Logs") { Task {
                await Logs.shared.logsAsCSV()
            }}
            Divider()
            Button("Quit") { NSApp.terminate(nil) }
        } label: {
            Image("menubar").frame(width: 30, height: 30)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var popover = NSPopover.init()
    static var shared : AppDelegate!
    var timeSpentAway: UInt64?
    
    override init() {
        super.init()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApp.setActivationPolicy(.accessory)
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        WindowsStore.shared.showSnowballsPanel()
    }
    
    
    func applicationDidResignActive(_ notification: Notification) {
    }
    
    func applicationDidHide(_ notification: Notification) {
    }
    
    func applicationDidChangeOcclusionState(_ notification: Notification) {
    }
}
