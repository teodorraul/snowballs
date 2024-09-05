//
//  chatHeader.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 9/2/24.
//

import Foundation
import AppKit

class ChatHeader: NSView {
    let label: NSTextField = NSTextField()
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        self.addSubview(label)
        
        
        label.isBordered = false
        label.drawsBackground = false
        label.isSelectable = false
        label.alignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.isEditable = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func setTitle(title: String) {
        label.stringValue = title
    }
}
