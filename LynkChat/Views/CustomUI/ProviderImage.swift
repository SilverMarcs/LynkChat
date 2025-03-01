//
//  ListRowImage.swift
//  LynkChat
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ListRowImage: View {
    var model: ModelImageProvider
    @Environment(\.appearsActive) private var appearsActive
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(hex: model.color).gradient)
                .frame(width: imageSize, height: imageSize)

            Image(model.imageName)
                .imageScale(.medium)
                .foregroundStyle(.white)
        }
        .opacity(appearsActive ? 1 : 0.7)
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
    ListRowImage(model: ChatModel.small_model)
}
