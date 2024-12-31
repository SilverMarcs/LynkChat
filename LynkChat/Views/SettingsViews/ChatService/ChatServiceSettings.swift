//
//  ChatServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ChatServiceSettings: View {
    @State private var selectedTab: ChatServiceTab = .models
    
    var body: some View {
        Group {
            switch selectedTab {
            case .models:
                ChatModelTable()
            case .parameters:
                ChatParameterSettings()
            case .plugins:
                ChatPluginSettings()
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                picker
            }
        }
    }
    
    var picker: some View {
        Picker("Tab", selection: $selectedTab) {
            ForEach(ChatServiceTab.allCases, id: \.self) { tab in
                Label(tab.rawValue, systemImage: tab.imageName)
                    .tag(tab)
                    #if os(macOS)
                    .labelStyle(.titleOnly)
                    #else
                    .labelStyle(.iconOnly)
                    #endif
            }
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }

}

#Preview {
    ChatServiceSettings()
}
