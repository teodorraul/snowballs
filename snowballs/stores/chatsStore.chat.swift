//
//  chatsStore.types.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 9/5/24.
//

import Foundation
import Combine

@MainActor
class Chat: Identifiable {
    let id: UUID
    var uiEvents: PassthroughSubject<MessageEvents, Never> = PassthroughSubject()
    var messages: [Message] = []
    var title: ChatTitle?
    
    
    init(_ id: UUID) {
        self.id = id
    }
    
    func saveTitle(title: ChatTitle) {
        self.title = title
    }
    
    func sendMessage(message: String, by: Message.Sender) {
        let id = UUID()
        let message = Message(id: id, from: by, text: message, chat: self)
        messages.append(message)
    
        Task { [weak self] in
            self?.uiEvents.send(.newMessage(id: id, sender: .user, html: message.text))
            
            await self?.createResponse()
        }
    }
    
    func createResponse() async {
        let responseId = UUID()
        let message = Message(id: responseId, from: .ai, text: "", chat: self)
        let receiver = MessageStreamReceiver(message: message, chat: self)
        message.saveReceiverStream(receiver: receiver)
        
        self.messages.append(message)
        self.uiEvents.send(.newMessage(id: responseId, sender: .ai, html: message.html))
        
        await ProvidersStore.shared.streamResponse(forChatId: self.id, intoMessageId: responseId, withMessagesContext: messages, receiver: receiver)
    }
}


enum MessageEvents {
    case newMessage(id: UUID, sender: Message.Sender, html: String)
    case messageUpdated(id: UUID, html: String)
    case messageCompletionFinished(id: UUID)
    case chatGainedTitle(title: ChatTitle)
}

enum ProviderEvents {
    case completionReceived(messageId: UUID, text: String)
}

struct ChatTitle {
    let fullTitle: String
    let shortened: String
    
    init(fullTitle: String) {
        self.fullTitle = fullTitle
        
        let words = fullTitle.split(separator: " ")
        
        if let firstWord = words.first {
            let abbr = String(firstWord.prefix(2))
            self.shortened = abbr + "."
        } else {
            self.shortened = "Unknown title"
        }
    }
}
