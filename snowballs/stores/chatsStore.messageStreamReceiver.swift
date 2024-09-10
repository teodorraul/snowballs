//
//  chatsStore.utils.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 9/5/24.
//

import Foundation
import Combine
import Markdown

actor MessageStreamReceiver {
    weak var message: Message?
    weak var chat: Chat?
    var cacheOfHighlightedCode: [Int: String] = [:]
    var lastTextCount = 0
    
    init(message: Message, chat: Chat) {
        self.message = message
        self.chat = chat
    }
    
    func textWillBeUpdated() async {
        if let chatId = chat?.id{
            await SnowballsStore.shared.uiEvents.send(.snowballIsLoading(id: chatId))
        }
    }
    
    //todo add final text
    func textIsNowComplete() async {
        guard let message = message else { return }
        
        await message.markAsCompleted()
    }
    
    var updateTask: Task<Void, Never>?
    
    func appendText(message text: String) async {
        guard let message = message else { return }
        
        let text = await message.appendPlainText(text: text)
        
        if let task = updateTask {
            task.cancel()
        }
        
        updateTask = Task {
            let html = self.getHTMLFromPlainText(text: text)
            await message.updateHTML(html: html)
        }
    }
    
    func informNoAPIKey() async {
        Logs.shared.core("tried to chat, no api key available")
        await self.appendText(message: "No API Key provided, set up your API Key in the Configure panel. You can access it by clicking the 🧤 mitten in the Menu Bar.")
    }
    
    func informError(err: String) async {
        Logs.shared.core("encountered an error while streaming: \(err)")
        await self.appendText(message: "\(err)")
    }
    
    func gainedTitleFromMessage(title: ChatTitle) async {
        await chat?.saveTitle(title: title)
        await chat?.uiEvents.send(.chatGainedTitle(title: title))
        if let chatId = chat?.id {
            await SnowballsStore.shared.uiEvents.send(.snowballGainedTitle(id: chatId, snowballTitle: title.fullTitle))
        }
    }
    
    private func getHTMLFromPlainText(text: String, skipCheckingIfLast: Bool = false) -> String {
        let ast = Document(parsing: text)
        
        for children in ast.children {
            guard let node = children as? CodeBlock else { continue }
            
            if skipCheckingIfLast ? false : node.indexInParent >= ast.childCount - 1 {
                continue
            }
                
            let highlightedCode = highlighter.highlight(node.code)
            
            if cacheOfHighlightedCode[node.indexInParent] == nil {
                cacheOfHighlightedCode[node.indexInParent] = highlightedCode
            }
        }
        
        var parser = MarkdownEngine()
        let html = parser.getHTML(from: ast, highlightedCodeCache: cacheOfHighlightedCode)
        
        return html
    }
}
