//
//  ProviderButton.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import SwiftUI
import SwiftData

struct ProviderButton: View {
    @Environment(\.modelContext) var modelContext
    let type: ProviderType
    @Query var providers: [Provider]
    
    var body: some View {
        Button(action: { addProvider(type: type) }) {
            Label(type.name, image: type.imageName)
        }
        .labelStyle(.titleAndIcon)
        .disabled(shouldDisableButton)
    }
    
    private var shouldDisableButton: Bool {
        // Allow multiple .custom providers
        if ProviderType.customTypes.contains(type) {
            return false
        }
        // Disable if provider type already exists
        return providers.contains(where: { $0.type == type })
    }
    
    private func addProvider(type: ProviderType) {
        let newProvider = Provider.factory(type: type)
        modelContext.insert(newProvider)
        try? modelContext.save()
    }
}

struct ProviderSection: View {
    let group: ProviderType.Group
    
    var body: some View {
        Section(header: Text(group.rawValue)) {
            ForEach(group.providers, id: \.self) { type in
                ProviderButton(type: type)
            }
        }
    }
}
