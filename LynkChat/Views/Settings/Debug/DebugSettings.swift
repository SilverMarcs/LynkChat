//
//  DebugSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import SwiftUI

struct DebugSettings: View {
    @Environment(\.openWindow) var openWindow
    @Environment(SettingsVM.self) var settingsVM
    
    @ObservedObject var config = AppConfig.shared
    @State private var showWebView = false
    
    var body: some View {
        Form {
            Section("API Settings") {
                TextField("API Key", text: $config.myApiKey)
                Toggle(isOn: $config.useLocalhost) {
                    Text("Use Localhost")
                    Text("Using \(String.apiHost)")
                }
                
                LabeledContent("Opens API Webview") {
                    Button("Open Window") {
                        #if os(macOS)
                        openWindow(id: WindowID.debugWeb)
                        #else
                        showWebView = true
                        #endif
                    }
                    #if !os(macOS)
                    .fullScreenCover(isPresented: $showWebView) {
                        DebugWebview()
                    }
                    #endif
                }
            }
            
            Section("Reset Settings") {
                LabeledContent {
                    Button("Reset First Launch") {
                        config.finishedInitialSetup = false
                    }
                } label: {
                    Text("First Launch Completed: \(String(config.finishedInitialSetup))")
                }
                
                LabeledContent {
                    Button("Reset Tips") {
                        config.resetTips.toggle()
                    }
                } label: {
                    Text("Will reset tips on next launch: \(String(config.resetTips))")
                }
            }
            
            Section("Debug Options") {
                Toggle("Print debug lines", isOn: $config.printDebgLogs)
                Toggle("Send debug model", isOn: $config.sendDebugModel)
            }
            
            Section("UI Settings") {
                Toggle("Show Raw Tool Response", isOn: $config.showUrlParsingResult)
            }
            
            Section {
                LabeledContent {
                    Button("Hide Debug") {
                        config.showDebugMenu.toggle()
                        settingsVM.settingsTab = .general
                    }
                } label: {
                    Text("Controls visibility of this page")
                }
                    
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
