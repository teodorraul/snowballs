//
//  markdown.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/31/24.
//

import Foundation
import Markdown

extension Document: Equatable {
    public static func ==(lhs: Document, rhs: Document) -> Bool {
        return lhs.isIdentical(to: rhs)
    }
}
