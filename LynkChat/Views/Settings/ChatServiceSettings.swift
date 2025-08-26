//
//  ChatServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ChatServiceSettings: View {
    @ObservedObject var config = ChatConfigDefaults.shared

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
