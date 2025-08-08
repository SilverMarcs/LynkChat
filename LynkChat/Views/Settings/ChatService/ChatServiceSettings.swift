//
//  ChatServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ChatServiceSettings: View {
    @State private var selectedTab: ChatServiceTab = .parameters
    
    var body: some View {
        tabView
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Tab", selection: $selectedTab) {
                        ForEach(ChatServiceTab.allCases, id: \.self) { tab in
                            Label(tab.rawValue, systemImage: tab.imageName)
                                .tag(tab)
                                .labelStyle(.titleOnly)
                        }
                    }
                    #if !os(macOS)
                    .controlSize(.large)
                    #endif
                    .pickerStyle(.segmented)
                }
            }
    }
    
    @ViewBuilder
    var tabView: some View {
        switch selectedTab {
        case .models:
            ChatModelTable()
        case .parameters:
            ChatParameterSettings()
        }
    }
}

#Preview {
    ChatServiceSettings()
}
