//
//  snowballsView.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import SwiftUI

let SNOWBALL_SIZE: CGFloat = 44
let SNOWBALL_PADDING: CGFloat = 20
let animationDuration = 0.22

struct SnowballsContainerView: View {
    @ObservedObject var snowballsStore = SnowballsStore.shared
    
    var body: some View {
        HStack() {
            GeometryReader { scrollGeo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 10) {
                        Spacer().frame(maxHeight: .infinity).layoutPriority(1)
                        ForEach(snowballsStore.snowballs, id: \.self.id){ snowball in
                            let isActive = snowball == snowballsStore.activeSnowball
                            if let state = snowballsStore.snowballsState[snowball.id] {
                                SnowballView(id: snowball.id, isActive: isActive, state: state)
                            } else {
                                EmptyView()
                            }
                        }
                    }.padding(20).frame(maxWidth: .infinity, minHeight: scrollGeo.size.height, maxHeight: .infinity)
                }.frame(maxHeight: .infinity, alignment: .bottom)
            }
            Spacer().frame(maxWidth: .infinity, maxHeight: .infinity).layoutPriority(1)
        }
    }
}
