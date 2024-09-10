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
    
    enum Payload {
        case delta(String)
        case error(String)
        case complete
    }
    
    func requestChatStream(query: ChatQuery, streamContinuation: AsyncStream<Payload>.Continuation) {
        openAI.chatsStream(query: query) { partialResult in
            switch partialResult {
            case .success(let result):
                if let choice = result.choices.first {
                    if let text = choice.delta.content {
                        streamContinuation.yield(.delta(text))
                    }
                }
            case .failure(let error):
                streamContinuation.yield(.error(error.localizedDescription))
            }
        } completion: { error in
            if let e = error {
                streamContinuation.yield(.error(e.localizedDescription))
            }
            streamContinuation.yield(.complete)
            streamContinuation.finish()
        }
    }
    
    func makeChatCompletionRequest(forChatId: UUID, intoMessageId: UUID, context: [ChatQuery.ChatCompletionMessageParam], receiver: MessageStreamReceiver) {
        var messages = context
        messages.insert(.system(.init(content: "If needed, format your responses using CommonMark markdown. Tend to keep responses concise.")), at: 0)
        let query = ChatQuery(messages: messages, model: ProvidersStore.shared.chosenModel)
        
        let count = messages.count
        
        var lastMsgLen = "<Unknown>"
        if messages.count >= 2 {
            // index -2, since last is the AI message we're completing
            let msg = messages[messages.count - 2]
            if let len = msg.content?.string {
                lastMsgLen = "\(len.count)"
            }
        }
        
        
        Logs.shared.core("starting request, message count: \(messages.count), last message length \(lastMsgLen)")
        
        let chatStream = AsyncStream<Payload> { continuation in
            requestChatStream(query: query, streamContinuation: continuation)
        }
        
        Task {
            for await result in chatStream {
                switch result {
                case .delta(let d):
                    await receiver.appendText(message: d)
                case .complete:
                    await receiver.textIsNowComplete()
                case .error(let err):
                    await receiver.informError(err: err)
                }
            }
        }
    }
}
