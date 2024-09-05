//
//  chatBox.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import AppKit



class ChatboxTextView: NSTextView, NSTextViewDelegate {
    public var onEnter: ((_ value: String) -> Void)?
    
    func setup() {
        self.isRichText = false
        self.textContainerInset = NSSize(width: 10, height: 10)
        self.backgroundColor = .clear
        self.isVerticallyResizable = true
        
        self.layer?.backgroundColor = .clear
        self.autoresizingMask = [.width]
                
        self.delegate = self
        
        self.font = NSFont.systemFont(ofSize: 13)
        
        if let container = self.textContainer {
            container.widthTracksTextView = true
        }
        
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    func textDidChange(_ notification: Notification) {
      guard let textView = notification.object as? NSTextView else { return }
      textView.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: NSSize {
      guard let manager = textContainer?.layoutManager else {
        return .zero
      }
      manager.ensureLayout(for: textContainer!)
        let size = manager.usedRect(for: textContainer!).size
        let insetedSize = CGSize(width: size.width + 20.0, height: size.height + 20.0)
      return insetedSize
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 || event.keyCode == 76 {
            let shiftKeyPressed = event.modifierFlags.contains(NSEvent.ModifierFlags.shift)
            if !shiftKeyPressed {
                if self.string != "" {
                    onEnter?(self.string)
                    self.textStorage?.setAttributedString(.init(string: ""))
                }
                return
            }
        }
        super.keyDown(with: event)
    }
}

class ChatboxView: NSView {
    var chatId: UUID
    public let field = ChatboxTextView()
    
    
    init(trackingChatId: UUID) {
        self.chatId = trackingChatId
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trackChat(chatId: UUID) {
        self.chatId = chatId
    }
    
    override func layout() {
        super.layout()
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    private func setupSubviews() {
        self.wantsLayer = true
        self.layer?.backgroundColor = .clear
        
        let scrollView = NSScrollView()
        field.setup()
        field.onEnter = { [weak self] value in
            if let chatId = self?.chatId {
                ChatsStore.shared.sendMessage(chatId: chatId, by: .user, message: value)
            }
        }
        field.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.documentView = field
        
        self.layer?.backgroundColor = .clear

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.wantsLayer = true
        scrollView.layer?.backgroundColor = NSColor.clear.cgColor
        scrollView.contentView.backgroundColor = .clear
        
        self.layer?.cornerRadius = 10.0
        self.clipsToBounds = true
        
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        NSLayoutConstraint.activateWithPriority([
            field.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ], 800)
    }
    
}
