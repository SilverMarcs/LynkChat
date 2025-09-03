//
//  SettingsView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
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
//                NavigationLink(destination: RAGSettings()) {
//                    Label("RAG Service", systemImage: Tool.rag.iconName)
//                }
                
                NavigationLink(destination: ChatServiceSettings()) {
                    Label("Chat Service", systemImage: "quote.bubble")
                }
                
                NavigationLink(destination: ImageServiceSettings()) {
                    Label("Image Service", systemImage: "photo")
                }
            }
            
            Section("Info") {
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
        .scrollContentBackground(.visible)
        #if !os(macOS) && !os(visionOS)
        .scrollDismissesKeyboard(.immediately)
        #endif
    }
}
