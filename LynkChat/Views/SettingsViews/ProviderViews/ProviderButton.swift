//
//  ProviderButton.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import SwiftUI

struct ProviderButton: View {
    @Environment(\.modelContext) var modelContext
    let type: ProviderType
    
    
    var body: some View {
        Button(action: { addProvider(type: type) }) {
            Label(type.name, image: type.imageName)
        }
        .labelStyle(.titleAndIcon)
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
