//
//  ListRowImage.swift
//  LynkChat
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ListRowImage: View {
    var model: ModelImageProvider
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(hex: model.color).gradient)
                .frame(width: imageSize, height: imageSize)

            Image(model.imageName)
                .imageScale(.medium)
                .foregroundStyle(.white)
        }
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
    ListRowImage(model: ChatModel.gpt4o)
}
