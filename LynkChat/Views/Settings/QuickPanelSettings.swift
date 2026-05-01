//
//  QuickPanelSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 12/07/2024.
//

import SwiftUI

struct QuickPanelSettings: View {
    @AppStorage("quickDefaultModel") private var quickDefaultModel: ChatModel = .gemini_flash
    @AppStorage("quickSystemPrompt") private var quickSystemPrompt: String = "Keep your responses fairly concise."
    
    var body: some View {
        Form {
            Section("Launch") {
                LabeledContent {
                    Text("⌃ + Space")
                        .monospaced()
                } label: {
                    Text("Global shortcut")
                    Text("Access from anywhere in the OS")
                }
            }
            
            ModelPicker(selectedModel: $quickDefaultModel, label: "Default Model")
            
            Section("System Prompt") {
                TextEditor(text: $quickSystemPrompt)
                    .font(.body)
                    .frame(height: 70)
                    .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Quick Panel")
        .formStyle(.grouped)
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    QuickPanelSettings()
}
