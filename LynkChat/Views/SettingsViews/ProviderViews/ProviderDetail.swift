//
//  ProviderDetail.swift
//  LynkChat
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderDetail: View {
    @Bindable var provider: Provider
    
    @State private var selectedTab: ProviderTab = .general

    var body: some View {
        content
            .scrollContentBackground(.visible)
            .navigationTitle(provider.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    picker
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        switch selectedTab {
        case .general:
            ProviderGeneral(provider: provider)
        case .models:
            ModelList(provider: provider)
        }
    }

    private var picker: some View {
        Picker("Tabs", selection: $selectedTab) {
           ForEach(ProviderTab.allCases) { type in
               Label(type.rawValue, systemImage: type.iconName)
                    .tag(type)
            }
        }
        #if os(macOS)
        .labelStyle(.titleOnly)
        #else
        .labelStyle(.iconOnly)
        #endif
        .pickerStyle(.segmented)
        .fixedSize()
    }
}

enum ProviderTab: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case general = "General"
    case models = "Models"
    
    var iconName: String {
        switch self {
        case .general:
            return "info.circle"
        case .models:
            return "quote.bubble"
        }
    }
}

#Preview {
    ProviderDetail(provider: .openAIProvider)
}
