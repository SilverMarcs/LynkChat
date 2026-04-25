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
    @AppStorage("autoCreateChatOnLaunch") var autoCreateChatOnLaunch: Bool = false
    @AppStorage("focusChatOnAppear") var focusChatOnAppear: Bool = false
    @AppStorage("hideDockIconWhenWindowClosed") var hideDockIconWhenWindowClosed: Bool = false
    
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
                
                #if !os(macOS)
                Toggle(isOn: $autoCreateChatOnLaunch) {
                    Text("Auto create chat on App Launch")
                }

                Toggle(isOn: $focusChatOnAppear) {
                    Text("Focus chat input when appears")
                }
                #endif

                #if os(macOS)
                Toggle(isOn: $hideDockIconWhenWindowClosed) {
                    Text("Hide Dock icon when window is closed")
                }
                #endif
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
