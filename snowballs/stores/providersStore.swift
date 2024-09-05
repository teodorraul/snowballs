//
//  coreStore.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/30/24.
//

import Foundation
import OpenAI

enum Provider {
    case openAI
    // case anthropic?
}

final class ProvidersStore: ObservableObject {
    static let shared = ProvidersStore()
    @Published var chosenModel: Model {
        didSet {
            UserDefaults.standard.set(chosenModel, forKey: "chosenModel")
        }
    }
    
    init() {
        self.chosenModel = UserDefaults.standard.string(forKey: "chosenModel") ?? .gpt4_o
    }
    
    func streamResponse(forChatId: UUID, intoMessageId: UUID, withMessagesContext: [Message], receiver: MessageStreamReceiver) async {
        if let key = fetchAPIKey(), key != "" {
            let oai = ProviderOpenAI(tkn: key)
            
            var messages: [ChatQuery.ChatCompletionMessageParam] = []
            
            for message in withMessagesContext {
                if await message.isFrom(.user) {
                    messages.append(.user(.init(content: .string(await message.text))))
                }
                if await message.isFrom(.ai) {
                    messages.append(.assistant(.init(content: await message.text)))
                }
            }
            
            let context = messages
            
            Task { [weak self] in
                await receiver.textWillBeUpdated()
                if let chat = await ChatsStore.shared.getChat(id: forChatId) {
                    if await chat.title == nil {
                        _ = await oai.makeGenerateTitleRequest(forChatId: forChatId, context: context, receiver: receiver)
                    }
                }
            }
            oai.makeChatCompletionRequest(forChatId: forChatId, intoMessageId: intoMessageId, context: context, receiver: receiver)
        } else {
            await receiver.informNoAPIKey()
        }
    }
    
    func fetchAPIKey() -> String? {
        let key = KeychainManager.retrieveAPIKey(account: "open-ai")
        return key
    }
    
    func saveAPIKey(forProvider: Provider, key: String) {
        KeychainManager.storeAPIKey(account: "open-ai", apiKey: key)
    }
}
