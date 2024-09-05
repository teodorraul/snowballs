//
//  akChatViewController.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import AppKit
import Combine

class ChatViewController: NSViewController {
    private let chatHeader: ChatHeader
    private let chatBackground = ChatBackground()
    private let messagesViewController: ChatMessagesViewController
    public let chatBox: ChatboxView
    private var chatId: UUID
    private var uiEventsListener: Cancellable?
    
    let pad = 10.0
    
    init(chatId: UUID, appReadyDelegate: WebkitAppReady) {
        chatHeader = ChatHeader()
        messagesViewController = ChatMessagesViewController(trackingChatId: chatId, appReadyDelegate: appReadyDelegate)
        chatBox = ChatboxView(trackingChatId: chatId)
        self.chatId = chatId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func focusInputField() {
        let window = self.view.window
        window?.makeFirstResponder(chatBox.field)
    }
    
    func setActiveChat(chatId: UUID) {
        self.chatId = chatId
        self.messagesViewController.trackChat(chatId: chatId)
        self.chatBox.trackChat(chatId: chatId)
        
        if let chat = ChatsStore.shared.getChat(id: chatId) {
            self.chatHeader.setTitle(title: chat.title?.fullTitle ?? "Untitled Chat")
            if let listener = uiEventsListener {
                listener.cancel()
            }
            uiEventsListener = chat.uiEvents.receive(on: RunLoop.main).sink { [weak self] event in
                if case let .chatGainedTitle(title) = event {
                    self?.chatHeader.setTitle(title: title.fullTitle)
                }
            }
        }
    }
    @objc func handleMouseUp(_ gestureRecognizer: NSGestureRecognizer) {
        focusInputField()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleMouseUp))
        view.addGestureRecognizer(clickRecognizer)
        
        self.view.addSubview(chatBackground)
        self.view.addSubview(chatHeader)
        
        chatBackground.addSubview(chatBox)
        
        chatBox.translatesAutoresizingMaskIntoConstraints = false
        chatBackground.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            chatBox.trailingAnchor.constraint(equalTo: chatBackground.trailingAnchor, constant: -pad),
            chatBox.bottomAnchor.constraint(equalTo: chatBackground.bottomAnchor, constant: -pad),
            chatBox.leadingAnchor.constraint(equalTo: chatBackground.leadingAnchor, constant: pad),
            chatBox.heightAnchor.constraint(equalToConstant: 84.0),
            chatBackground.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -pad),
            chatBackground.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -pad),
            chatBackground.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: pad),
            chatBackground.topAnchor.constraint(equalTo: self.view.topAnchor, constant: pad)
        ])
        
        self.view.wantsLayer = false
        self.view.clipsToBounds = false
        
        
        // Message VC
        self.addChild(messagesViewController)
        self.view.addSubview(messagesViewController.view)
        
        messagesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        messagesViewController.view.clipsToBounds = true
        
        chatHeader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatHeader.topAnchor.constraint(equalTo: chatBackground.topAnchor, constant: 0),
            chatHeader.leadingAnchor.constraint(equalTo: chatBackground.leadingAnchor, constant: 0),
            chatHeader.trailingAnchor.constraint(equalTo: chatBackground.trailingAnchor, constant: 0),
            chatHeader.heightAnchor.constraint(equalToConstant: 50.0),
            messagesViewController.view.topAnchor.constraint(equalTo: chatHeader.bottomAnchor, constant: 0),
            messagesViewController.view.leadingAnchor.constraint(equalTo: chatBackground.leadingAnchor, constant: 0),
            messagesViewController.view.trailingAnchor.constraint(equalTo: chatBackground.trailingAnchor, constant: 0),
            messagesViewController.view.bottomAnchor.constraint(equalTo: chatBox.topAnchor, constant: -10)
        ])
    }
}
