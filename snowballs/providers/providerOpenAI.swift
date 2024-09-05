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

        Logs.shared.core("starting title completion request")
        
        openAI.chats(query: query) { result in
            Task { [weak self] in
                switch result {
                case .success(let res):
                    if let choice = res.choices.first {
                        if let response = choice.message.content?.string {
                            await receiver.gainedTitleFromMessage(title: ChatTitle(fullTitle: response))
                        }
                    } else {
                        Logs.shared.core("no title choices returned")
                    }
                case .failure(let error):
                    Logs.shared.core("title generation failed \(error.localizedDescription)")
                }
            }
        }
    }
    
    func makeChatCompletionRequest(forChatId: UUID, intoMessageId: UUID, context: [ChatQuery.ChatCompletionMessageParam], receiver: MessageStreamReceiver) {
        var messages = context
        messages.insert(.system(.init(content: "If needed, format your responses using CommonMark markdown. Tend to keep responses concise.")), at: 0)
        let query = ChatQuery(messages: messages, model: ProvidersStore.shared.chosenModel)
        
        var lastMsgLen = messages.last?.content?.string ?? "-1"
        if let len = messages.last?.content as? String {
            lastMsgLen = len
        }
        
        Logs.shared.core("starting request, message count: \(messages.count), last message length \(lastMsgLen)")
        

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
                Task { [weak self] in
                    await receiver.informError(err: error.localizedDescription)
                }
            }
        } completion: { error in
            Task { [weak self] in
                if let e = error {
                    Logs.shared.core("response errored out \(e.localizedDescription)")
                } else {
                    Logs.shared.core("response completed")
                }
                await receiver.textIsNowComplete()
            }
        }
    }
}
