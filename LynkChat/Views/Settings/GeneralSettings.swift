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
            
            Section("Behaviour") {
                LabeledContent("Restart Onboarding") {
                    Button("Launch") {
                        config.hasCompletedOnboarding = false
                    }
                }
            }
            
            Section("Appearance") {
                Slider(value: $config.fontSize, in: 8...25, step: 1) {
                    Text("Font Size")
                } minimumValueLabel: {
                    Text("")
                        .monospacedDigit()
                } maximumValueLabel: {
                    Text("\(Int(config.fontSize))")
                        .monospacedDigit()
                }
            }
            .sectionActions {
                Button("Reset") {
                    config.resetFontSize()
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
