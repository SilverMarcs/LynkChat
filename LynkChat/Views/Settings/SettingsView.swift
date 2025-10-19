//
//  SettingsView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct SettingsView: View {
    @SceneStorage("selectedCategory") var selectedCategory: SettingsCategory = .general
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            list
                .navigationSplitViewColumnWidth(min: 220, ideal: 220, max: 220)
        } detail: {
            NavigationStack {
                selectedCategory.destination
            }
        }
        #else
        NavigationStack {
            list
        }
        #endif
    }
    
    var list: some View {
        Group {
            #if os(macOS)
            List(selection: $selectedCategory) {
                listItems
            }
            .toolbar(removing: .sidebarToggle)
            .toolbar {
                Button {
                    
                } label: {
                    Image(systemName: "info")
                }
                .hidden()
            }
            #else
            List {
                listItems
            }
            .navigationDestination(for: SettingsCategory.self) { category in
               category.destination
            }
            .scrollDismissesKeyboard(.immediately)
            #endif
        }
        .toolbarTitleDisplayMode(.inlineLarge)
        .navigationTitle("Settings")
        .scrollContentBackground(.visible)
    }
    
    @ViewBuilder
    var listItems: some View {
        Section("Config") {
            #if os(macOS)
            ForEach([SettingsCategory.general, .shortcuts], id: \.self) { category in
                NavigationLink(value: category) {
                    Label(category.rawValue, systemImage: category.systemImage)
                }
            }
            #else
            NavigationLink(value: SettingsCategory.general) {
                Label(SettingsCategory.general.rawValue, systemImage: SettingsCategory.general.systemImage)
            }
            #endif
        }
        
        Section("Services") {
            ForEach([SettingsCategory.audioService, .chatService, .imageService], id: \.self) { category in
                NavigationLink(value: category) {
                    Label(category.rawValue, systemImage: category.systemImage)
                }
            }
        }
        
        Section("Info") {
            ForEach([SettingsCategory.about], id: \.self) { category in
                NavigationLink(value: category) {
                    Label(category.rawValue, systemImage: category.systemImage)
                }
            }
        }
    }
}
