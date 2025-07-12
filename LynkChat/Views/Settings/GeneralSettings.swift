//
//  GeneralSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI
import SwiftData

struct GeneralSettings: View {
    @Environment(\.modelContext) var modelContext
    
    @ObservedObject var config = AppConfig.shared

    var body: some View {
        Form {
            Section("Title") {
                Toggle(isOn: $config.autogenTitle) {
                    Text("Autogenerate Title")
                }
            }
            
            Section("Misc") {
                Toggle(isOn: $config.enterToSend) {
                    Text("Enter to send message")
                    Text("Enabling this makes input area laggy and is not recommended")
                }
            }
            
            Section {
                LabeledContent("Restart Onboarding") {
                    Button("Launch") {
                        config.hasCompletedOnboarding = false
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    GeneralSettings()
}
