//
//  ListRowImage.swift
//  LynkChat
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ListRowImage: View {
    var model: ModelImageProvider
    #if os(macOS)
    @Environment(\.appearsActive) private var appearsActive
    #endif
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(hex: model.color).gradient)
                .frame(width: imageSize, height: imageSize)

            Image(model.imageName)
                .imageScale(.medium)
                .foregroundStyle(.white)
        }
        #if os(macOS)
        .opacity(appearsActive ? 1 : 0.7)
        #endif
    }
    
    var imageSize: CGFloat {
        #if os(macOS)
        return 22
        #else
        return 26
        #endif
    }
}

#Preview {
    let registry = ModelRegistry.shared
    let enabledModels = registry.getEnabledModels()
    let modelInfo = enabledModels.first ?? ModelInfo(providerId: UUID(), modelString: "mock", displayName: "Mock")
    let provider = registry.getProvider(modelInfo.providerId) ?? ModelProvider(name: "Mock", baseURL: "mock", apiKey: "mock")
    let chatModel = ChatModel(providerId: provider.id, modelInfoId: modelInfo.id)
    ListRowImage(model: chatModel)
}
