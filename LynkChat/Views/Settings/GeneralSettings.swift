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
    #if os(macOS)
    @AppStorage("fontSize") var fontSize: Double = 13
    #else
    @AppStorage("fontSize") var fontSize: Double = 17
    #endif

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
                    #if os(macOS)
                    fontSize = 13
                    #else
                    fontSize = 17
                    #endif
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
