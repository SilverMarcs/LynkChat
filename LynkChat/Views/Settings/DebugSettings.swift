//
//  DebugSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import SwiftUI

struct DebugSettings: View {
    @Environment(\.openWindow) var openWindow
    
    @State var config = AppConfig()
    @State private var showWebView = false
    
    var body: some View {
        Form {
            Section("API Settings") {
                TextField("API Key", text: $config.myApiKey)
                
                Toggle(isOn: $config.useLocalhost) {
                    Text("Use Localhost")
                    Text(String.apiHost.replacingOccurrences(of: "/api", with: ""))
                }
            }
            
            Section("Debug Options") {
                Toggle("Print debug lines", isOn: $config.printDebgLogs)
                Toggle("Send debug model", isOn: $config.sendDebugModel)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Debug")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    DebugSettings()
}
