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
    @Environment(SettingsVM.self) private var settingsVM
    
    @ObservedObject var config = AppConfig.shared

    var body: some View {
        Form {
            Section("Title") {
                Toggle(isOn: $config.autogenTitle) {
                    Text("Autogenerate Title")
                }
            }
            
            Section("Misc") {
                #if os(macOS)
                Toggle(isOn: $config.onlyOneWindow) {
                    Text("Show one window at a time")
                    Text("If enabled, chat window will be closed when image window is opened and vice versa")
                }
                #endif
                
                Toggle(isOn: $config.enterToSend) {
                    Text("Enter to send message")
                    Text("Enabling this makes input area laggy and is not recommended")
                }
                
            }
            
            Section {
                LabeledContent("Restart Onboarding") {
                    Button("Launch") {
                        settingsVM.showSettings = false
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
