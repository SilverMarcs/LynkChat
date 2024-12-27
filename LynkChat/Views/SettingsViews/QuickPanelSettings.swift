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
    @ObservedObject var config = AppConfig.shared
    @ObservedObject var modelConfig = ModelConfig.shared
    
    var body: some View {
        Form {
            Section("Launch") {
                LabeledContent {
//                    KeyboardShortcuts.Recorder(for: .togglePanel)
                    Text("⌥ + Space")
                } label: {
                    Text("Global shortcut")
                    Text("Access from anywhere in the OS")
                }
            }
                
            Picker("Model", selection: $modelConfig.quickModel) {
                ForEach(LynkModel.allCases) { model in
                    Text(model.rawValue)
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
