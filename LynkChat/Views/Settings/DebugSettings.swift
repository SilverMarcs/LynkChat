//
//  DebugSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import SwiftUI

struct DebugSettings: View {
    @ObservedObject var config = AppConfig.shared
    
    var body: some View {
        Form {
            TextField("API Key", text: $config.myApiKey)
            Toggle(isOn: $config.useLocalhost) {
                Text("Use Localhost")
                Text("Using \(String.apiHost)")
            }
            
            LabeledContent {
                Button("Reset Chat filter usage") {
                    config.hasUsedChatStatusFilter = false
                }
            } label: {
                Text("Reset Chat filter usage: \(config.hasUsedChatStatusFilter)")
            }

            LabeledContent {
                Button("Reset First Launch") {
                    config.finishedInitialSetup = false
                }
            } label: {
                Text("First Launch Completed: \(config.finishedInitialSetup)")
            }
            
            LabeledContent {
                Button("Reset Tips") {
                    config.resetTips.toggle()
                }
            } label: {
                Text("Will reset tips on next launch: \(config.resetTips)")
            }
            
            Toggle("Print debug lines", isOn: $config.printDebgLogs)
        }
        .formStyle(.grouped)
        .navigationTitle("Debug")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    DebugSettings()
}
