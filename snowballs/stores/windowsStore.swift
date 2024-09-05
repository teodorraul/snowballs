//
//  windowsStore.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import AppKit
import SwiftUI

@MainActor final class WindowsStore {
    static let shared = WindowsStore()
    
    var adjustHotkeysWindow: NSWindow?
    var configurationWindow: NSWindow?
    private var activeBallPosition: CGPoint?
    private var snowballsPanel: SnowballsPanel?
    private var chatPanel: ChatPanel?
    
    func showSnowballsPanel() {
        self.snowballsPanel = SnowballsPanel()
        if let panel = snowballsPanel {
            panel.orderFrontRegardless()
            panel.canHide = false
            panel.ignoresMouseEvents = true
            if let height = NSScreen.main?.frame.height {
                panel.setFrame(NSRect(x: 0, y: 0, width: SNOWBALL_SIZE + SNOWBALL_PADDING * 2, height: height), display: true)
            }
        }
    }
    
    private var chatPanelIsTransitioning = false
    private var chatPanelIsHidden = false
    
    func setActiveChat(origin: CGPoint, ballHeight: CGFloat, chatId: UUID){
        activeBallPosition = origin
        let panelWidth = 540.0
        let panelHeight = 800.0
        
        let menuBarSize = 14.0
        if let screen = NSScreen.main {
            let newOrigin = ballHeight - menuBarSize - 30
            
            if chatPanel == nil {
                let panel = ChatPanel(chatId: chatId)
                self.chatPanel = panel
            }
            
            if let panel = chatPanel {
                panel.setActiveChat(chatId: chatId)
                
                panel.setFrame(NSRect(x: origin.x + SNOWBALL_SIZE + 10, y: newOrigin, width: panelWidth, height: panelHeight), display: true)
                activateChatPanel()
            }
        }
    }
    
    func activateChatPanel() {
        if let panel = chatPanel, !panel.isKeyWindow {
            panel.makeKeyAndOrderFront(nil)
            if let vc = panel.contentViewController as? ChatViewController {
                panel.makeFirstResponder(vc.chatBox.field)
            }
        }
    }
    
    func dismissChatPanel() {
        if let panel = chatPanel {
            NSApp.hide(nil)
            panel.close()
            self.chatPanel = nil
        }
    }
    
    func showConfigureWindow() {
        let vc = NSHostingController(rootView: ConfigurationView())
        
        if let win = configurationWindow {
            win.center()
            win.makeKeyAndOrderFront(nil)
            win.orderFrontRegardless()
        } else {
            configurationWindow = NSWindow(contentViewController: vc)
            if let panel = configurationWindow {
                configurationWindow?.title = "Snowballs Configuration"
                panel.setFrame(NSRect(x: 0, y: 0, width: 400, height: 200), display: true)
                panel.center()
                panel.makeKeyAndOrderFront(nil)
                panel.orderFrontRegardless()
            }
        }
    }
    
    func showAdjustHotkeysWindow() {
        let vc = NSHostingController(rootView: AdjustHotkeysView())
        
        if let win = adjustHotkeysWindow {
            win.center()
            win.makeKeyAndOrderFront(nil)
            win.orderFrontRegardless()
        } else {
            adjustHotkeysWindow = NSWindow(contentViewController: vc)
            if let panel = adjustHotkeysWindow {
                configurationWindow?.title = "Snowballs Adjust Hotkeys"
                panel.setFrame(NSRect(x: 0, y: 0, width: 300, height: 300), display: true)
                panel.center()
                panel.makeKeyAndOrderFront(nil)
                panel.orderFrontRegardless()
            }
        }
    }
}
