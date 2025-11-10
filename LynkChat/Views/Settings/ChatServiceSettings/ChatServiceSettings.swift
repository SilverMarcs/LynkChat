//
//  ChatServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ChatServiceSettings: View {
    @AppStorage("defaultModel") private var defaultModel: ChatModel = .gemini_flash
    @AppStorage("temperature") private var temperature: Temperature = .balanced
    @AppStorage("systemPrompt") private var systemPrompt: String = String.systemPrompt

    var body: some View {
        Form {
            ModelPicker(selectedModel: $defaultModel, label: "Default Model")
            
            Section("Parameters") {
                Picker("Behaviour", selection: $temperature) {
                    ForEach(Temperature.allCases, id: \.self) { option in
                        Text(option.name).tag(option)
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
                        systemPrompt = String.systemPrompt
                    } label: {
                        Text("Default")
                            .fontWeight(.regular)
                    }
                }
            }
        }
        .navigationTitle("Chat Parameters")
        .toolbarTitleDisplayMode(.inline)
        .formStyle(.grouped)
    }
    
    var sysPrompt: some View {
        TextEditor(text: $systemPrompt)
            .font(.body)
            .scrollContentBackground(.hidden)
            .labelsHidden()
            .frame(maxHeight: 275)
    }
}

#Preview {
    ChatServiceSettings()
}
