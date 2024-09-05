//
//  snowballsContainer.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import SwiftUI

class SnowballsPanel: NSPanel, NSWindowDelegate {
    init() {
        super.init(contentRect: CGRect.zero, styleMask: [.fullSizeContentView, .borderless, .nonactivatingPanel], backing: .buffered, defer: true)
        
        let vc = NSHostingController(rootView: SnowballsContainerView())
        self.contentViewController = vc
        self.isFloatingPanel = true
        self.level = .init(9999999999)
        self.isReleasedWhenClosed = false
          
        self.hasShadow = false
          
        self.isMovable = false
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.titlebarSeparatorStyle = .none
        self.delegate = self
          
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        self.isOpaque = false
        self.backgroundColor = NSColor(.clear)
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
    func windowWillClose(_ notification: Notification) {
        self.contentViewController = nil
    }
    override var canBecomeKey: Bool {
      return false
    }

    override var canBecomeMain: Bool {
      return false
    }
}
