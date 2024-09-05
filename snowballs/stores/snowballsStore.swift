//
//  snowballsStore.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import KeyboardShortcuts
import Cocoa
import Combine

struct Snowball: Identifiable, Equatable {
    let id: UUID
}

enum SnowballEvents {
    case snowballIsLoading(id: UUID)
    case snowballIsDone(id: UUID)
    case snowballGainedTitle(id: UUID, snowballTitle: String)
}

struct SnowballState: Equatable {
    var title: String
    var isLoading: Bool
}

@MainActor
final class SnowballsStore: ObservableObject {
    static let shared = SnowballsStore()
    private var lastActiveSnowball: Snowball?
    @Published var snowballs: [Snowball] = []
    @Published var activeSnowball: Snowball? {
        didSet {
            if activeSnowball != nil {
                lastActiveSnowball = activeSnowball
            } else {
                WindowsStore.shared.dismissChatPanel()
            }
        }
    }
    var uiEvents: PassthroughSubject<SnowballEvents, Never> = PassthroughSubject()
    private var uiEventsListener: Cancellable?
    @Published var snowballsState: [UUID: SnowballState] = [:]
    
    init() {
        self.uiEventsListener = uiEvents.receive(on: RunLoop.main).sink { [weak self] event in
            guard let self = self else { return }
            switch (event) {
            case let .snowballGainedTitle(id, title):
                if let snowball = self.snowballsState[id] {
                    var newSnowball = snowball
                    newSnowball.title = title
                    self.snowballsState[id] = newSnowball
                }
            case let .snowballIsDone(id):
                if let snowball = self.snowballsState[id] {
                    var newSnowball = snowball
                    newSnowball.isLoading = false
                    self.snowballsState[id] = newSnowball
                }
            case let .snowballIsLoading(id):
                if let snowball = self.snowballsState[id] {
                    var newSnowball = snowball
                    newSnowball.isLoading = true
                    self.snowballsState[id] = newSnowball
                }
            }
        }
        registerHotkeys()
    }
    
    func registerHotkeys() {
        KeyboardShortcuts.onKeyDown(for: .toggleSnowballs) { [weak self] in
            self?.toggleSnowballs()
        }
        KeyboardShortcuts.onKeyDown(for: .selectNextSnowball) { [weak self] in
            self?.selectNextSnowball()
        }
        KeyboardShortcuts.onKeyDown(for: .selectPrevSnowball) { [weak self] in
            self?.selectPrevSnowball()
        }
        KeyboardShortcuts.onKeyDown(for: .throwBall) { [weak self] in
            self?.throwActiveBall()
        }
    }
    
    func toggleSnowballs() {
        if activeSnowball == nil {
            if snowballs.count > 0 {
                if let last = lastActiveSnowball, snowballs.first(where: { $0.id == last.id }) != nil {
                    activeSnowball = lastActiveSnowball
                } else {
                    activeSnowball = snowballs.first
                }
            } else {
                addSnowball()
            }
            WindowsStore.shared.activateChatPanel()
        } else {
            resignActiveBall()
        }
    }
    
    func selectNextSnowball() {
        NSApplication.shared.activate()
        if let i = snowballs.firstIndex(where: { $0 == activeSnowball }) {
            if i > 0 {
                activeSnowball = snowballs[i - 1]
            }
            if i == 0 {
                addSnowball()
            }
        } else if snowballs.count > 0 {
            if let last = lastActiveSnowball, snowballs.first(where: { $0.id == last.id }) != nil {
                activeSnowball = lastActiveSnowball
            } else {
                activeSnowball = snowballs.first
            }
        } else {
            addSnowball()
            activeSnowball = snowballs.first
        }
    }
    
    func selectPrevSnowball() {
        NSApplication.shared.activate()
        if let i = snowballs.firstIndex(where: { $0 == activeSnowball }) {
            if i < snowballs.count - 1 {
                activeSnowball = snowballs[i + 1]
            }
        } else if snowballs.count > 0 {
            if let last = lastActiveSnowball, snowballs.first(where: { $0.id == last.id }) != nil {
                activeSnowball = lastActiveSnowball
            } else {
                activeSnowball = snowballs[snowballs.count - 1]
            }
        } else {
            addSnowball()
            activeSnowball = snowballs.first
        }
    }
    
    func throwActiveBall() {
        if let i = snowballs.firstIndex(where: { $0 == activeSnowball }) {
            if i + 1 < snowballs.count {
                activeSnowball = snowballs[i + 1]
            } else {
                if snowballs.count > 1 {
                    activeSnowball = snowballs[snowballs.count - 2]
                } else {
                    activeSnowball = nil
                }
            }
            snowballs.remove(at: i)
        }
        
    }
    
    func resignActiveBall() {
        activeSnowball = nil
    }

    func addSnowball() {
        NSApplication.shared.activate()
        let newSnowball = Snowball(id: UUID())
        self.snowballsState[newSnowball.id] = .init(title: "", isLoading: false)
        snowballs.insert(newSnowball, at: 0)
        activeSnowball = newSnowball
    }
    
    func markActive(snowball: Snowball) {
        activeSnowball = snowball
    }
}
