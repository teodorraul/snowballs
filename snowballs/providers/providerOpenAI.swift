//
//  streaming.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import OpenAI
import Combine

class ProviderOpenAI {
    let openAI: OpenAI
    var result: AnyCancellable? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init(tkn: String) {
        self.openAI = OpenAI(apiToken: tkn)
    }
    
    func makeGenerateTitleRequest(forChatId: UUID, context: [ChatQuery.ChatCompletionMessageParam], receiver: MessageStreamReceiver) async {
        var messages: [ChatQuery.ChatCompletionMessageParam] = context.count > 0 ? [context.first!] : []
       messages.insert(.system(.init(content: "Always describe in only 3 words the user's intent behind the next prompt. First word should always be a noun highly related to the subject of the prompt.")), at: 0)
       let query = ChatQuery(messages: messages, model: .gpt4_o_mini)

        openAI.chats(query: query) { result in
            Task { [weak self] in
                switch result {
                case .success(let res):
                    if let choice = res.choices.first {
                        if let response = choice.message.content?.string {
                            await receiver.gainedTitleFromMessage(title: ChatTitle(fullTitle: response))
                        }
                    } else {
                        print("failed to get chat title")
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func makeChatCompletionRequest(forChatId: UUID, intoMessageId: UUID, context: [ChatQuery.ChatCompletionMessageParam], receiver: MessageStreamReceiver) {
        var messages = context
        messages.insert(.system(.init(content: "If needed, format your responses using CommonMark markdown. Tend to keep responses concise.")), at: 0)
        let query = ChatQuery(messages: messages, model: ProvidersStore.shared.chosenModel)
        //gpt4_0125_preview

        openAI.chatsStream(query: query) { partialResult in
            switch partialResult {
            case .success(let result):
                if let choice = result.choices.first {
                    if let text = choice.delta.content {
                        Task { [weak self] in
                            await receiver.appendText(message: text)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        } completion: { error in
            Task { [weak self] in
                //todo
                await receiver.textIsNowComplete()
            }
        }
    }
}
