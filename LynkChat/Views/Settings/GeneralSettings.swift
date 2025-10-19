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
    
    @State var config = AppConfig()
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("fontSize") var fontSize: Double = Double.defaultFontSize

    var body: some View {
        Form {
            Section("Title") {
                Toggle(isOn: $config.autogenTitle) {
                    Text("Autogenerate Title")
                }
            }
            
            Section("Behaviour") {
                HStack {
                    Text("Restart Onboarding")
                    Spacer()
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
                    resetFontSize()
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
        .toolbarTitleDisplayMode(.inline)
    }
    
    func resetFontSize() {
        #if os(macOS)
        fontSize = 13
        #else
        fontSize = 17
        #endif
    }
}

#Preview {
    GeneralSettings()
}
