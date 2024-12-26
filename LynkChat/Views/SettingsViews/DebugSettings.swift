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
            Toggle("Send Own Key", isOn: $config.sendOwnKey)
            TextField("API Host", text: $config.myApiHost)
            TextField("API Key", text: $config.myApiKey)
        }
        .formStyle(.grouped)
        .navigationTitle("Debug")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    DebugSettings()
}
