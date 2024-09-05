//
//  snowballsView.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import AppKit
import SwiftUI
import Cocoa
import Combine
import Markdown
import WebKit


class ChatMessagesViewController: NSViewController {
    private var webView: RenderingWebView!
    private var chatUiEventsListener: Cancellable?
    private var trackingChatId: UUID
    private weak var isAppReadyDelegate: WebkitAppReady?
    
    init(trackingChatId: UUID, appReadyDelegate: WebkitAppReady) {
        self.trackingChatId = trackingChatId
        super.init(nibName: nil, bundle: nil)
        self.isAppReadyDelegate = appReadyDelegate
        
        webView = RenderingWebView(onReady: { [weak self] in
            Task { [weak self] in
                await self?.setupRenderer()
                self?.isAppReadyDelegate?.appIsNowReady()
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupRenderer() async {
        guard let chat = ChatsStore.shared.getChat(id: trackingChatId) else { return }
        
        var chatHTML = ""
        
        for message in chat.messages {
            chatHTML += """
<div class=\"message \(message.getFrom())\" id="\(message.id)">\(message.isFrom(.user) ? "<p>\(message.text)</p>" : message.html)</div>
"""
        }
        
        do {
            _ = try await self.webView.invokeAction(.init(payload: .showChat(html: chatHTML )))
        } catch {
            print("failed to track chat", error)
        }
        
        self.chatUiEventsListener = chat.uiEvents.sink { [weak self] event in
            Task { [weak self] in
                switch (event) {
                case let .messageUpdated(id, html):
                    _ = try? await self?.webView.invokeAction(.init(payload: .updateMessage(id: id.uuidString, html: html )))
                case let .newMessage(id, sender, html):
                    _ = try? await self?.webView.invokeAction(.init(payload: .newMessage(id: id.uuidString, sender: .init(sender: sender), html: html)))
                default:
                    break
                }
            }
        }

    }
    
    func trackChat(chatId: UUID) {
        guard chatId != self.trackingChatId else { return }
        self.trackingChatId = chatId
        
        Task { [weak self] in
            await self?.setupRenderer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -0),
            webView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        webView.wantsLayer = true
        webView.layer?.backgroundColor = .clear
        webView.underPageBackgroundColor = .clear
        webView.enclosingScrollView?.backgroundColor = .clear
        webView.layer?.isOpaque = false
        webView.setValue(false, forKey: "drawsBackground")
        
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "renderer") {
            let htmlURL = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        }
    }
}
