//
//  DebugSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import SwiftUI

struct DebugSettings: View {
    @AppStorage("myApiKey") var myApiKey: String = ""
    @AppStorage("useLocalhost") var useLocalhost = false
    @AppStorage("printDebgLogs") var printDebgLogs = false

    @Environment(GodMode.self) var godMode

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
            }

            Section {
                Button(role: .destructive) {
                    godMode.deactivate()
                } label: {
                    Text("Deactivate God Mode")
                }
            } header: {
                Text("God Mode")
            } footer: {
                Text("All models are unlocked.")
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
