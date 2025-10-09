//
//  ChatServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ChatServiceSettings: View {
    @State var config: ChatConfigDefaults = .init()
    
    @AppStorage("geminiApiKey") private var geminiApiKey = ""
    @AppStorage("openaiApiKey") private var openaiApiKey = ""
    @AppStorage("anthropicApiKey") private var anthropicApiKey = ""
    @AppStorage("xaiApiKey") private var xaiApiKey = ""

    var body: some View {
        Form {
            ModelPicker(selectedModel: $config.defaultModel, label: "Default Model")
            
            Section("Parameters") {
                Picker("Behaviour", selection: $config.temperature) {
                    ForEach(Temperature.allCases, id: \.self) { option in
                        Text(option.name).tag(option)
                    }
                }
            }
            
//            Section("Plugins") {
//                ForEach([Tool.webSearch, Tool.imageGeneration], id: \.self) { tool in
//                    Label {
//                        Text(tool.title)
//                        Text(tool.description)
//                    } icon: {
//                        Image(systemName: tool.iconName)
//                    }
//                }
//            }

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
            
            Section("API Keys") {
                SecureField("Gemini API Key", text: $geminiApiKey)
                SecureField("OpenAI API Key", text: $openaiApiKey)
                SecureField("Anthropic API Key", text: $anthropicApiKey)
                SecureField("xAI API Key", text: $xaiApiKey)
            }
        }
        .navigationTitle("Chat Parameters")
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
}

#Preview {
    ChatServiceSettings()
}
