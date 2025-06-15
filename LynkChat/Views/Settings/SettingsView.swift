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
    
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    
    @ObservedObject var config = AppConfig.shared
    
    var body: some View {
        @Bindable var settingsVM = settingsVM
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $settingsVM.settingsTab) {
                Label("General", systemImage: "gear")
                    .tag(SettingsTab.general)
                
                Label("Appearance", systemImage: "paintbrush")
                    .tag(SettingsTab.appearance)
                
                #if os(macOS)
                Label("Quick Panel", systemImage: "bolt.fill")
                    .tag(SettingsTab.quickPanel)
                #endif
                   
                Label("Chat Service", systemImage: "quote.bubble")
                    .tag(SettingsTab.chat)
                
                Label("Image Service", systemImage: "photo")
                    .tag(SettingsTab.image)
                
                #if os(macOS)
                Label("Shortcuts", systemImage: "command")
                    .tag(SettingsTab.shortcuts)
                #endif
                
                Label("About", systemImage: "info.circle")
                    .tag(SettingsTab.about)
                
                if config.showDebugMenu {
                    Label("Debug", systemImage: "ladybug")
                        .tag(SettingsTab.debug)
                }
                         
            }
            .toolbar(removing: .sidebarToggle)
            .navigationSplitViewColumnWidth(min: 190, ideal: 190, max: 190)
            #if !os(visionOS)
            .navigationTitle("Settings")
            #endif
        } detail: {
            NavigationStack {
                switch settingsVM.settingsTab {
                case .general:
                    GeneralSettings()
                case .appearance:
                    AppearanceSettings()
                #if os(macOS)
                case .quickPanel:
                    QuickPanelSettings()
                #endif
                case .chat:
                    ChatServiceSettings()
                case .image:
                    ImageServiceSettings()
                #if os(macOS)
                case .shortcuts:
                    ShortcutSettings()
                #endif
                case .about:
                    AboutSettings()
                case .debug:
                    DebugSettings()
                default:
                    EmptyView()
                }
            }
            #if !os(macOS) && !os(visionOS)
            .scrollDismissesKeyboard(.immediately)
            #endif
            .scrollContentBackground(.visible)
            .onChange(of: columnVisibility, initial: true) { oldVal, newVal in
                if newVal == .detailOnly {
                    DispatchQueue.main.async {
                        columnVisibility = .all
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
