//
//  SettingsView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(SettingsVM.self) private var settingsVM
    @ObservedObject var config = AppConfig.shared
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            list
        } detail: {
            Text("Select a category from the sidebar to view its settings.")
                .foregroundStyle(.secondary)
                .padding()
        }
        #else
        NavigationStack {
            list
        }
        #endif
    }
    
    var list: some View {
        List {
            Section("Config") {
                NavigationLink(destination: GeneralSettings()) {
                    Label("General", systemImage: "gear")
                }
                
                NavigationLink(destination: AppearanceSettings()) {
                    Label("Appearance", systemImage: "paintbrush")
                }
                
                #if os(macOS)
                NavigationLink(destination: QuickPanelSettings()) {
                    Label("Quick Panel", systemImage: "bolt.fill")
                }
                
                NavigationLink(destination: ShortcutSettings()) {
                    Label("Shortcuts", systemImage: "command")
                }
                #endif
            }
            
            Section("Services") {
                NavigationLink(destination: ChatServiceSettings()) {
                    Label("Chat Service", systemImage: "quote.bubble")
                }
                
                NavigationLink(destination: ImageServiceSettings()) {
                    Label("Image Service", systemImage: "photo")
                }
            }
            
            Section("Info & Troubleshooting") {
                NavigationLink(destination: AboutSettings()) {
                    Label("About", systemImage: "info.circle")
                }
                
                NavigationLink(destination: DebugSettings()) {
                    Label("Debug", systemImage: "ladybug")
                }
            }
        }
        .toolbarTitleDisplayMode(.inlineLarge)
        .navigationTitle("Settings")
        #if !os(macOS) && !os(visionOS)
        .scrollDismissesKeyboard(.immediately)
        #endif
        .scrollContentBackground(.visible)
    }
}
