//
//  adjustHotkeysView.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import SwiftUI
import KeyboardShortcuts

struct AdjustHotkeysView: View {
    @ObservedObject var snowballsStore = SnowballsStore.shared
    @State var text = ""

    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Open / Close Chat:").frame(width: 150, alignment: .leading)
                Spacer().frame(maxWidth: .infinity)
                KeyboardShortcuts.Recorder("", name: .toggleSnowballs).frame(width: 200)
            }
            HStack {
                Text("Next chat:").multilineTextAlignment(.leading).frame(width: 150, alignment: .leading)
                Spacer().frame(maxWidth: .infinity)
                KeyboardShortcuts.Recorder("", name: .selectNextSnowball).frame(width: 200)
            }
            HStack {
                Text("Previous chat:").multilineTextAlignment(.leading).frame(width: 150, alignment: .leading)
                Spacer().frame(maxWidth: .infinity)
                KeyboardShortcuts.Recorder("", name: .selectPrevSnowball).frame(width: 200)
            }
            HStack {
                Text("Delete chat:").multilineTextAlignment(.leading).frame(width: 150, alignment: .leading)
                Spacer().frame(maxWidth: .infinity)
                KeyboardShortcuts.Recorder("", name: .throwBall).frame(width: 200)
            }
        }.padding(40).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
