//
//  ChatServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ChatServiceSettings: View {
    @State var config: ChatConfigDefaults = .init()

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
            
            Section("MCP Servers") {
                NavigationLink {
                    MCPServerManagementView(servers: $config.mcpServers)
                } label: {
                    HStack {
                        Label("Manage Servers", systemImage: "server.rack")
                        Spacer()
                        Text("\(config.mcpServers.count) configured")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
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
