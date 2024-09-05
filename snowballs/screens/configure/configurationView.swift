//
//  configurationView.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import SwiftUI
import KeyboardShortcuts
import OpenAI
import LaunchAtLogin

struct ConfigurationView: View {
    @ObservedObject var snowballsStore = SnowballsStore.shared
    @ObservedObject var providersStore = ProvidersStore.shared
    @State var text = ""
    let availableModels: [Model]  =  [
        .gpt3_5Turbo_0125,
        .gpt3_5Turbo_16k,
        .gpt3_5Turbo,
        .gpt4_o_mini,
        .gpt4,
        .gpt4_0125_preview,
        .gpt4_o,
        .gpt4_0613,
        .gpt4_turbo
    ]

    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Text("OpenAI API Key").multilineTextAlignment(.leading).frame(width: 160, alignment: .leading)
                    Spacer()
                    SecureField("", text: $text).textContentType(.password).onChange(of: text, {
                        ProvidersStore.shared.saveAPIKey(forProvider: .openAI, key: text)
                    }).onAppear() {
                        if let key = ProvidersStore.shared.fetchAPIKey() {
                            text = key
                        }
                    }.frame(width: 210)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                HStack(spacing: 10) {
                    Text("GPT Model:").multilineTextAlignment(.leading).frame(width: 160, alignment: .leading)
                    Spacer()
                    Picker("", selection: Binding(get: {
                        return providersStore.chosenModel
                    }, set: { val in
                        providersStore.chosenModel = val
                    })) {
                        ForEach(availableModels, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()).frame(width: 220)
                }
                Divider()
                HStack(spacing: 10) {
                    HStack {
                        LaunchAtLogin.Toggle {
                            Text("Launch Snowballs at Login")
                        }
                    }
                    Spacer().frame(maxWidth: .infinity)
                }
            }.padding(20)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}
