//
//  snowball.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 9/5/24.
//

import Foundation
import SwiftUI

struct SnowballView: View {
    let id: UUID
    let isActive: Bool
    let state: SnowballState

    var body: some View {
        ZStack(alignment: .center) {
            GeometryReader { circleGeo in
                ZStack(alignment: .center) {
                    if isActive {
                        Circle().fill(LinearGradient(colors: [.white, Color(NSColor(red: 0.87, green: 0.961, blue: 1, alpha: 1))], startPoint: .topLeading, endPoint: .topTrailing) ).frame(width: SNOWBALL_SIZE, height: SNOWBALL_SIZE).opacity(1)
                            .overlay(
                                Circle().fill(Color(NSColor(red: 0.32, green: 0.511, blue: 0.55, alpha: 1))).frame(width: SNOWBALL_SIZE, height: SNOWBALL_SIZE).mask {
                                    Circle().fill(
                                        RadialGradient(gradient: Gradient(colors: [Color.clear, Color.black]), center: .center, startRadius: (SNOWBALL_SIZE / 2) - 15, endRadius: SNOWBALL_SIZE / 2 + 20))
                                    .frame(width: SNOWBALL_SIZE + 10, height: SNOWBALL_SIZE + 10).offset(x: -3, y: -3)
                                })
                    } else {
                        Circle().fill(Color(NSColor.black.withAlphaComponent(0.2))).frame(width: SNOWBALL_SIZE, height: SNOWBALL_SIZE)
                    }
                    if isActive {
                        Circle().frame(width: 0, height: 0).onAppear() {
                            let o = circleGeo.frame(in: .global)
                            WindowsStore.shared.setActiveChat(origin: CGPoint(x: o.minX, y: o.minY), ballHeight: o.height, chatId: id)
                        }.transition(.opacity).animation(.easeInOut(duration: animationDuration), value: isActive)
                    }
                    Circle().fill(.clear).frame(width: SNOWBALL_SIZE, height: SNOWBALL_SIZE).overlay {
                        if !state.isLoading {
                            if state.title != "" {
                                Text(state.title).font(.system(size: 13, weight: .semibold)).multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center).foregroundStyle(isActive ? .black : .white).animation(.easeInOut(duration: animationDuration), value: isActive)
                            } else {
                                Circle().fill(.white).frame(width: 4, height: 4).opacity(0.25)
                            }
                        }
                        if state.isLoading {
                            if isActive {
                                ProgressView().scaleEffect(x: 0.75, y: 0.75).colorInvert()
                            } else {
                                ProgressView().scaleEffect(x: 0.75, y: 0.75)
                            }
                        }
                    }
                }
            }.zIndex(100)
            Circle().stroke(isActive ? Color(NSColor(white: 1.0, alpha: 0.6)) : Color(NSColor(white: 1.0, alpha: 0.2)), lineWidth: isActive ? 2 : 1.5)
                .frame(width: SNOWBALL_SIZE + 8, height: SNOWBALL_SIZE + 8).offset(x: -4, y: -4).scaleEffect(x: isActive ? 1.0 : 0.82, y: isActive ? 1.0 : 0.82).zIndex(1000)
                .animation(.easeInOut(duration: animationDuration), value: isActive)
        }.frame(width: SNOWBALL_SIZE + 6, height: SNOWBALL_SIZE + 6, alignment: .center)

    }
}
