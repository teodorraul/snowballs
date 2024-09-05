//
//  hotkeysListener.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import Carbon
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleSnowballs = Self("toggleSnowballs", default: .init(.q, modifiers: [.option]))
    static let selectNextSnowball = Self("selectNextSnowball", default: .init(.w, modifiers: [.option]))
    static let selectPrevSnowball = Self("selectPrevSnowball", default: .init(.s, modifiers: [.option]))
    static let throwBall = Self("throwBall", default: .init(.d, modifiers: [.option]))
}
