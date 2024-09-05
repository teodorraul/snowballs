//
//  webviewCommunicatorEngine.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 9/1/24.
//

import Foundation
import Cocoa
import WebKit

final class RenderingWebView: WKWebView, WKScriptMessageHandler, WKNavigationDelegate, WKURLSchemeHandler {
    func invokeAction(_ action: RendererAction) async throws -> Any? {
        do {
            guard let payload = try action.jsonString(encoding: .utf8)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
        
            return try await withCheckedThrowingContinuation { [weak self] continuation in
                self?.evaluateJavaScript("window.invokeAction(\"\(payload)\")") { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: result)
                    }
                }
            }
        } catch {
            print("Error serializing JSON: \(error)")
        }
        
        return nil
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    var DEBUG = false
    
    init(onReady: @escaping () -> Void) {
        let userScriptSource = """
        \(DEBUG == true ? """
                window.console.log = function(...msg) {
                    let message = msg.map((m) => m + "").join(" ");
                    window.webkit.messageHandlers.logHandler.postMessage(message);
                };
                window.console.error = function(...msg) {
                    let message = msg.map((m) => m + "").join(" ");
                    window.webkit.messageHandlers.logHandler.postMessage(message);
                };
                window.onerror = function(message, source, lineno, colno, error) {
                    var errorMessage = "JavaScript error: " + message + " at " + source + ":" + lineno + ":" + colno;
                    if (error && error.stack) {
                        errorMessage += "\\n" + error.stack;
                    }
                    window.webkit.messageHandlers.errorHandler.postMessage(errorMessage);
                    return false; // Return true to prevent the default handling of the error
                };
            """ : "")
        """
        let userScript = WKUserScript(source: userScriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.userContentController.addUserScript(userScript)
    
        self.onReady = onReady
        super.init(frame: .zero, configuration: configuration)
        configuration.setURLSchemeHandler(self, forURLScheme: "custom")
        
        self.navigationDelegate = self
        
        let weakMessageHandler = WeakScriptMessageHandler(delegate: self)
        self.configuration.userContentController.add(weakMessageHandler, name: "logHandler")
        self.configuration.userContentController.add(weakMessageHandler, name: "errorHandler")
        self.configuration.userContentController.add(weakMessageHandler, name: "core")
    }
    
    deinit {
        self.configuration.userContentController.removeScriptMessageHandler(forName: "logHandler")
        self.configuration.userContentController.removeScriptMessageHandler(forName: "errorHandler")
        self.configuration.userContentController.removeScriptMessageHandler(forName: "core")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var onReady: () -> Void
    public private(set) var isReady = false
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "core" {
            if let messageBody = message.body as? String {
                if messageBody == "appIsReady" {
                    print("App is ready")
                    self.isReady = true
                    onReady()
                }
            }
        }
        if message.name == "logHandler", let messageBody = message.body as? String {
            print("JavaScript console.log: \(messageBody)")
        } else if message.name == "errorHandler", let messageBody = message.body as? String {
            print("JavaScript error: \(messageBody)")
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, shouldAllowNavigation(to: url) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
        
        // Allow opening links returned by GPT in Safari
        if let url = navigationAction.request.url {
            if url != self.url {
                NSWorkspace.shared.open(url)
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let url = navigationResponse.response.url, shouldAllowNavigation(to: url) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }

    func shouldAllowNavigation(to url: URL) -> Bool {
        if (url == self.url) {
            return true
        }
        return false
    }
    
    // Block any WebView trafic
    func webView(_ webView: WKWebView, start URLSchemeTask: WKURLSchemeTask) {
        URLSchemeTask.didFailWithError(NSError(domain: "Blocked", code: 0, userInfo: nil))
    }

    func webView(_ webView: WKWebView, stop URLSchemeTask: WKURLSchemeTask) {
    }
}

class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
