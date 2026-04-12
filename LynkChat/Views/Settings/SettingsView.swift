//
//  SettingsView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(GodMode.self) var godMode
    @SceneStorage("selectedCategory") var selectedCategory: SettingsCategory = .general
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            list
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
            .toolbar {
                Button(role: .close) {
                    dismiss()
                }
            }
            .navigationDestination(for: SettingsCategory.self) { category in
               category.destination
            }
            .scrollDismissesKeyboard(.immediately)
            #endif
        }
        .toolbarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
        .scrollContentBackground(.visible)
    }
    
    @ViewBuilder
    var listItems: some View {
        Section("Config") {
            #if os(macOS)
            ForEach([SettingsCategory.general, .quickPanel, .shortcuts], id: \.self) { category in
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
            let services: [SettingsCategory] = godMode.isActivated ? [.chatService, .imageService] : [.chatService]
            ForEach(services, id: \.self) { category in
                NavigationLink(value: category) {
                    Label(category.rawValue, systemImage: category.systemImage)
                }
            }
        }

        Section("Info") {
            let info: [SettingsCategory] = godMode.isActivated ? [.about, .debug] : [.about]
            ForEach(info, id: \.self) { category in
                NavigationLink(value: category) {
                    Label(category.rawValue, systemImage: category.systemImage)
                }
            }
        }
    }
}
