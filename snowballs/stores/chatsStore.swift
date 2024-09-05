//
//  chatsStore.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/30/24.
//

import Foundation
import Combine
import Cocoa
import Markdown



@MainActor
final class ChatsStore: ObservableObject {
    static let shared = ChatsStore()
    private var chats: [UUID: Chat] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    
    func getChat(id: UUID) -> Chat? {
        if chats[id] != nil {
            return chats[id]
        } else {
            chats[id] = Chat(id)
            return chats[id]
        }
    }
    
    func sendMessage(chatId: UUID, by: Message.Sender, message: String) {
        if let chat = getChat(id: chatId) {
            chat.sendMessage(message: message, by: by)
        }
    }
}
