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
            ModelPicker(selectedModel: $config.defaultModel, label: "Default Model")
            
            Section("Parameters") {
                Picker("Behaviour", selection: $config.temperature) {
                    ForEach(Temperature.allCases, id: \.self) { option in
                        Text(option.name).tag(option)
                    }
                }
                
//                Picker("Max Tokens", selection: $config.maxTokens) {
//                    ForEach(MaxTokens.allCases, id: \.self) { option in
//                        Text(option.description)
//                            .tag(option)
//                    }
//                }
            }
            
            Section("Plugins") {
                ForEach([Tool.webSearch, Tool.imageGeneration], id: \.self) { tool in
                    Label {
                        Text(tool.title)
                        Text(tool.description)
                    } icon: {
                        Image(systemName: tool.iconName)
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
        .navigationTitle("Chat Parameters")
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
