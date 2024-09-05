//
//  chatPanel.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import SwiftUI


protocol WebkitAppReady: NSObject {
    func appIsNowReady() -> Void
}



class ChatPanel: NSPanel, NSWindowDelegate, WebkitAppReady {
    func appIsNowReady() {
        self.alphaValue = 1.0
    }
    
    init(chatId: UUID) {
        super.init(contentRect: CGRect.zero, styleMask: [.fullSizeContentView, .resizable, .nonactivatingPanel], backing: .buffered, defer: false)
        
        self.alphaValue = 0.0
        self.contentViewController = ChatViewController(chatId: chatId, appReadyDelegate: self)
        
        self.isFloatingPanel = true
        self.level = .init(10)
        self.isReleasedWhenClosed = false
          
        self.hasShadow = false
          
        self.isMovable = true
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.titlebarSeparatorStyle = .none
        self.delegate = self
          
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        self.isOpaque = false
        self.backgroundColor = .clear
        
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
    }
    
    func setActiveChat(chatId: UUID) {
        if let vc = self.contentViewController as? ChatViewController {
            vc.setActiveChat(chatId: chatId)
        }
    }
    
    private var startedDraggingAt: NSPoint?
    
    override func mouseDown(with event: NSEvent) {
        startedDraggingAt = event.locationInWindow
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        guard startedDraggingAt != nil else { return }
        
        let loc = event.locationInWindow
        if let sat = startedDraggingAt {
            let newOrigin = NSPoint(
                x: frame.origin.x + (loc.x - sat.x),
                y: frame.origin.y + (loc.y - sat.y)
            )
            setFrameOrigin(newOrigin)
        }
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        if let vc = self.contentViewController as? ChatViewController {
            vc.focusInputField()
        }
    }
    
    func windowDidChangeOcclusionState(_ notification: Notification) {
        if let vc = self.contentViewController as? ChatViewController {
            vc.focusInputField()
        }
    }
    
    func windowDidBecomeMain(_ notification: Notification) {
        if let vc = self.contentViewController as? ChatViewController {
            vc.focusInputField()
        }
    }
    
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
    
    func windowWillClose(_ notification: Notification) {
        self.contentViewController = nil
    }
    
    override var canBecomeKey: Bool {
      return true
    }

    override var canBecomeMain: Bool {
      return true
    }
}
