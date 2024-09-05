//
//  markdown.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 9/1/24.
//

import Foundation
import Markdown
import Splash

let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())

public struct MarkdownEngine: MarkupVisitor {
    let baseFontSize: CGFloat = 15.0
    var highlightedCodeCache: [Int: String] = [:]
    
    public typealias Result = String
    
    public init() {}
    
    public mutating func getHTML(from document: Document, highlightedCodeCache: [Int: String]) -> String {
        self.highlightedCodeCache = highlightedCodeCache
        return visit(document)
    }
    
    mutating public func defaultVisit(_ markup: Markup) -> String {
        var result = ""
        
        for child in markup.children {
            result.append(visit(child))
        }
        
        return result
    }
    
    mutating public func visitText(_ text: Text) -> String {
        return text.plainText
    }
    
    mutating public func visitEmphasis(_ emphasis: Emphasis) -> String {
        var result = ""
        
        for child in emphasis.children {
            result.append("<i>" + visit(child) + "</i>")
        }
        
        return result
    }
    
    mutating public func visitStrong(_ strong: Strong) -> String {
        var result = ""
        
        for child in strong.children {
            result.append("<b>" + visit(child) + "</b>")
        }
        
        return result
    }
    
    mutating public func visitParagraph(_ paragraph: Paragraph) -> String {
        var result = "<p>"
        
        for child in paragraph.children {
            result.append(visit(child))
        }
        
        return result + "</p>"
    }
    
    mutating public func visitHeading(_ heading: Heading) -> String {
        var result = "<h\(heading.level)>"
        
        for child in heading.children {
            result.append(visit(child))
        }
        
        return result + "</h\(heading.level)>"
    }
    
    mutating public func visitLink(_ link: Link) -> String {
        var result = "<a href=\"\(link.destination ?? "#")\">"
        
        for child in link.children {
            result.append(visit(child))
        }
        
        return result + "</a>"
    }
    
    mutating public func visitInlineCode(_ inlineCode: InlineCode) -> String {
        return "<code>" + inlineCode.code.encodeHTMLEntities() + "</code>"
    }
    
    public func visitCodeBlock(_ codeBlock: CodeBlock) -> String {
        var code = codeBlock.code
        
        if let cachedAndHighlightedCode = highlightedCodeCache[codeBlock.indexInParent] {
            code = cachedAndHighlightedCode
        } else {
            code = code.encodeHTMLEntities()
        }
        
            
        return "<pre><code \(codeBlock.language != nil ? "class=\"language-\(codeBlock.language!)\" data-lang=\"\(codeBlock.language!)\"" : "" )>\(code)</code></pre>"
    }
    
    mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> String {
        var result = ""
        
        for child in strikethrough.children {
            result.append("<s>" + visit(child) + "</s>")
        }
        
        return result
    }
    
    mutating public func visitUnorderedList(_ unorderedList: UnorderedList) -> String {
        var result = "<ul>"
                
        for listItem in unorderedList.listItems {
            result += visit(listItem)
        }
        result += "</ul>"
        
        return result
    }
    
    mutating public func visitListItem(_ listItem: ListItem) -> String {
        var result = "<li>"
        
        for child in listItem.children {
            result += visit(child)
        }
        
        result += "</li>"
        
        return result
    }
    
    mutating public func visitOrderedList(_ orderedList: OrderedList) -> String {
        var result = "<ol>"
                
        for listItem in orderedList.listItems {
            result += visit(listItem)
        }
        result += "</ol>"
        
        return result
    }
    
    mutating public func visitBlockQuote(_ blockQuote: BlockQuote) -> String {
        var result = "<blockquote>"
                
        for listItem in blockQuote.children {
            result += visit(listItem)
        }
        result += "</blockquote>"
        
        return result
    }
}
