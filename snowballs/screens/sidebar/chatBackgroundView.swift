//
//  chatView.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import AppKit

class ChatBackground: NSView {
    let background = NSView()
    
    override init(frame rect: NSRect) {
        super.init(frame: rect)
  
        
        self.addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: self.topAnchor),
            background.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            background.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            background.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        background.clipsToBounds = true
        background.wantsLayer = true
        background.layer?.cornerRadius = 16.0
        
        background.wantsLayer = true
        background.layer?.backgroundColor = NSColor.background.cgColor
        background.layer?.borderWidth = 0.5
        background.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
    

    }
    
    override func layout() {
        super.layout()
        updateShadow()
    }
    
    private func updateShadow() {
        guard let layer = self.layer else { return }
        
        let shadowPath = NSBezierPath(rect: CGRect(x: bounds.origin.x + 8,
                                                   y: bounds.origin.y + 3,
                                                   width: bounds.size.width - 16,
                                                   height: bounds.size.height - 13))
        self.layer?.shadowPath = shadowPath.cgPath
        self.layer?.shadowOpacity = 1
        self.layer?.shadowOffset = CGSize(width: 0, height: 0)
        self.layer?.shadowRadius = 6
        self.layer?.shadowColor = NSColor.black.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
