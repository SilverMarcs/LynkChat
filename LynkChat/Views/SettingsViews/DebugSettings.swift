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
            
            LabeledContent {
                Button("Reset First Launch") {
                    config.finishedInitialSetup = false
                }
            } label: {
                Text(String(config.finishedInitialSetup))
            }
            
            Toggle("Print debug ines", isOn: $config.printDebgLogs)
        }
        .formStyle(.grouped)
        .navigationTitle("Debug")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    DebugSettings()
}
