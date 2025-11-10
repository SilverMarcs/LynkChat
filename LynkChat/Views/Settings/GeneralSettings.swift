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
    
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("fontSize") var fontSize: Double = 13

    var body: some View {
        Form {
            Section("Title") {
                Toggle(isOn: $autogenTitle) {
                    Text("Autogenerate Title")
                }
            }
            
            Section("Behaviour") {
                LabeledContent("Restart Onboarding") {
                    Button("Launch") {
                        hasCompletedOnboarding = false
                    }
                }
            }
            
            #if os(macOS)
            Section("Appearance") {
                Slider(value: $fontSize, in: 8...25, step: 1) {
                    Text("Font Size")
                } minimumValueLabel: {
                    Text("")
                        .monospacedDigit()
                } maximumValueLabel: {
                    Text("\(Int(fontSize))")
                        .monospacedDigit()
                }
            }
            .sectionActions {
                Button("Reset") {
                    fontSize = 13
                }
            }
            #endif
        }
        .formStyle(.grouped)
        .navigationTitle("General")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    GeneralSettings()
}
