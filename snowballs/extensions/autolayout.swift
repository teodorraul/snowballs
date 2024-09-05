//
//  autolayout.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/31/24.
//

import Foundation
import AppKit

extension NSLayoutConstraint {
    static func activateWithPriority(_ constraints: [NSLayoutConstraint], _ priority: Float = 999) {
        constraints.forEach { constraint in
            constraint.priority = NSLayoutConstraint.Priority(priority)
            constraint.isActive = true
        }
    }
}
