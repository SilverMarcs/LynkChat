//
//  ChatServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ChatServiceSettings: View {
    @State private var selectedTab: ServiceTab = .models
    
    var body: some View {
        Group {
            switch selectedTab {
            case .models:
                ChatModelTable()
            case .parameters:
                ParameterSettings()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                picker
            }
        }
    }
    
    var picker: some View {
        Picker("Tab", selection: $selectedTab) {
            ForEach(ServiceTab.allCases, id: \.self) { tab in
                Label(tab.rawValue, systemImage: tab.imageName)
                    .tag(tab)
                    .labelStyle(.titleOnly)
            }
        }
        .pickerStyle(.segmented)
    }

}

#Preview {
    ChatServiceSettings()
}
