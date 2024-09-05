//
//  renderingWebView.bridge.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 9/5/24.
//

import Foundation

enum RendererActionPayload: Codable, Sendable {
    enum Sender: String, Codable {
        case user = "user"
        case ai = "ai"
        
        init(sender: Message.Sender) {
            switch sender {
            case .ai:
                self = Sender.ai
            case .user:
                self = Sender.user
            }
        }
    }
    
    case newMessage(id: String, sender: Sender, html: String)
    case updateMessage(id: String, html: String)
    case showChat(html: String)

    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case sender
        case html
        case show
    }

    private enum ActionType: String, Codable {
        case newMessage
        case updateMessage
        case showChat
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .showChat(let html):
            try container.encode(ActionType.showChat, forKey: .type)
            try container.encode(html, forKey: .html)
        case .newMessage(let id, let sender, let html):
            try container.encode(ActionType.newMessage, forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(sender, forKey: .sender)
            if sender == .user {
                try container.encode("<p>\(html)</p>", forKey: .html)
            } else {
                try container.encode(html, forKey: .html)
            }
        case .updateMessage(let id, let html):
            try container.encode(ActionType.updateMessage, forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(html, forKey: .html)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)

        switch type {
        case .showChat:
            let html = try container.decode(String.self, forKey: .html)
            self = .showChat(html: html)
        case .newMessage:
            let id = try container.decode(String.self, forKey: .id)
            let sender = try container.decode(Sender.self, forKey: .sender)
            let html = try container.decode(String.self, forKey: .html)
            self = .newMessage(id: id, sender: sender, html: html)

        case .updateMessage:
            let id = try container.decode(String.self, forKey: .id)
            let html = try container.decode(String.self, forKey: .html)
            self = .updateMessage(id: id, html: html)
        }
    }
}

struct RendererAction: Codable, Sendable {
    var payload: RendererActionPayload
    
    enum Sender: String {
        case user = "user"
        case ai = "ai"
    }
    
    func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
