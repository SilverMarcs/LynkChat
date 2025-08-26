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
    @State var config: ChatConfigDefaults = .init()
    
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
