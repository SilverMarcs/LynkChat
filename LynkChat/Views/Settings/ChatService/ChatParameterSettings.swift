//
//  ChatParameterSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

struct ChatParameterSettings: View {
    @ObservedObject var config = ChatConfigDefaults.shared
    @State var expandAdvanced: Bool = true

    var body: some View {
        Form {
            Section("Model") {
                ModelPicker(selectedModel: $config.defaultModel, label: "Default")
            }
            
            Section("Basic") {
                Slider(
                    value: Binding(
                        get: { Double(config.temperature) },
                        set: { config.temperature = Double($0) }
                    ),
                    in: 0...2,
                    step: 0.1,
                    label: { Text("Temperature") },
                    minimumValueLabel: {
                        Text("")
                            .frame(width: 0)
                    },
                    maximumValueLabel: {
                        Text(String(format: "%.1f", config.temperature))
                        #if os(macOS)
                            .frame(width: 17)
                        #else
                            .frame(width: 25)
                        #endif
                    }
                )
                
                Picker("Max Tokens", selection: $config.maxTokens) {
                    ForEach(MaxTokens.allCases, id: \.self) { option in
                        Text(option.description)
                            .tag(option)
                    }
                }
            }

            Section {
                sysPrompt
            } header: {
                HStack {
                    Text("System Prompt")
                    Spacer()
                    Button {
                        config.systemPrompt = String.systemPrompt
                    } label: {
                        Text("Default")
                            .fontWeight(.regular)
                    }
                }
            }
        }
        .navigationTitle("Parameters")
        .toolbarTitleDisplayMode(.inline)
        .formStyle(.grouped)
    }
    
    var sysPrompt: some View {
        TextEditor(text: $config.systemPrompt)
            .font(.body)
            .scrollContentBackground(.hidden)
            .labelsHidden()
            .frame(maxHeight: 275)
    }
    
    var lineLimit: Int {
        #if os(macOS)
        15
        #else
        5
        #endif
    }
}

#Preview {
    ChatParameterSettings()
}
