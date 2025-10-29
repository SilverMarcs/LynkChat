//
//  DebugSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import SwiftUI

struct DebugSettings: View {
    @Environment(\.openWindow) var openWindow
    
    @AppStorage("myApiKey") var myApiKey: String = ""
    @AppStorage("useLocalhost") var useLocalhost = false
    @AppStorage("printDebgLogs") var printDebgLogs = false
    @AppStorage("sendDebugModel") var sendDebugModel = false
    @State private var showWebView = false
    
    var body: some View {
        Form {
            Section("API Settings") {
                TextField("API Key", text: $myApiKey)
                
                Toggle(isOn: $useLocalhost) {
                    Text("Use Localhost")
                    Text(String.apiHost.replacingOccurrences(of: "/api", with: ""))
                }
            }
            
            Section("Debug Options") {
                Toggle("Print debug lines", isOn: $printDebgLogs)
                Toggle("Send debug model", isOn: $sendDebugModel)
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
