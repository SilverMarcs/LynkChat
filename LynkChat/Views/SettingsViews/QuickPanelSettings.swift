//
//  QuickPanelSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 12/07/2024.
//

import SwiftUI
import SwiftData

struct QuickPanelSettings: View {
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = ChatConfigDefaults.shared
    @ObservedObject var modelConfig = ModelConfig.shared
    
    var body: some View {
        Form {
            Section("Launch") {
                LabeledContent {
                    Text("⌥ + Space")
                        .monospaced()
                } label: {
                    Text("Global shortcut")
                    Text("Access from anywhere in the OS")
                }
            }
                
            Picker("Model", selection: $modelConfig.quickModel) {
                ForEach(ChatModel.allCases) { model in
                    Text(model.name)
                        .tag(model)
                }
            }
                
            Section("System Prompt") {
                TextEditor(text: $config.quickSystemPrompt)
                    .font(.body)
                    .frame(height: 70)
                    .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Quick Panel")
        .formStyle(.grouped)
    }
}

#Preview {
    QuickPanelSettings()
}
