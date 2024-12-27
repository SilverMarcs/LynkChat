//
//  ProviderImage.swift
//  LynkChat
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderImage: View {
    // TODO: simplify this
//    var provider: ProviderImageProvider
    
    var radius: CGFloat = 9
    var frame: CGFloat = 25
    
    var scale: Image.Scale
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
//                .fill(Color(hex: provider.color).gradient)
                .fill(Color(hex: "#5755C5").gradient)
                .frame(width: frame, height: frame)

//            Image(provider.imageName)
            Image("storm.SFSymbol")
//                .foregroundStyle(provider.type == .ollama ? .black : .white)
                .imageScale(scale)
        }
    }
}

//#Preview {
//    ProviderImage(provider: .openAIProvider, scale: .small)
//}
