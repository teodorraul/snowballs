//
//  chatsStore.message.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 9/5/24.
//

import Foundation
import Markdown

@MainActor
class Message: Identifiable {
    let id: UUID
    private let from: Sender
    private var createdAt: Date
    private var updatedAt: Date
    private var streamReceiver: MessageStreamReceiver?
    public let contentsBuilder: MessageContentsBuiler
    public private(set) var text = ""
    public private(set) var html = ""
    weak var chat: Chat?
    
    init(id: UUID, from: Sender, text: String, chat: Chat) {
        self.id = id
        self.from = from
        self.createdAt = Date()
        self.updatedAt = Date()
        self.contentsBuilder = MessageContentsBuiler()
        self.text = text
        self.html = text
        self.chat = chat
    }
    
    enum Sender {
        case user
        case ai
    }
    
    func getFrom() -> Sender {
        return from
    }
    
    
    func isFrom(_ sender: Sender) -> Bool {
        return from == sender
    }
    
    func setPlainText(text: String) {
        self.text = text
    }
    
    func appendPlainText(text: String) -> String {
        self.text += text
        return self.text
    }
    
    func markAsCompleted() {
        if let chatId = self.chat?.id {
            SnowballsStore.shared.uiEvents.send(.snowballIsDone(id: chatId))
        }
    }
    
    func updateHTML(html: String) {
        if self.html.count < html.count {
            self.html = html
        }
        chat?.uiEvents.send(.messageUpdated(id: self.id, html: self.html))
    }
    
    func setHTML(html: String) {
        self.html = html
    }
    
    func saveReceiverStream(receiver: MessageStreamReceiver) {
        self.streamReceiver = receiver
    }
}

class MessageContentsBuiler {
}
