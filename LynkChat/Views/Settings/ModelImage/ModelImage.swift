//
//  ModelImage.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ModelImage: View {
    // TODO: simplify this
    var model: ModelImageProvider
    
    var radius: CGFloat = 4.5
    var frame: CGFloat = 15
    
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(Color(hex: model.color).gradient)
                .frame(width: frame, height: frame)

            Image(model.imageName)
                .imageScale(.small)
        }
    }
}

#Preview {
    ModelImage(model: ChatModel.small_model)
}
