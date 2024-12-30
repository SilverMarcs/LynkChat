//
//  ToolImageView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI
import TipKit

struct ToolImageView: View {
    var urlStr: String
    
    var body: some View {
        // TODO: save to gallery btn
        AsyncImage(url: URL(string: urlStr)) { phase in
            if let image = phase.image {
                image
                    .resizable()
            } else if phase.error != nil {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.red.quinary)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.red)
                        .frame(width: 75, height: 75)
                }
            } else {
                ToolImagePlaceholderView()
            }
        }
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
        // TODO: check this
        TipView(ImageGenToolTip())
            .frame(width: 300, height: 50)
        
    }
}

#Preview {
    ToolImageView(urlStr: "https://picsum.photos/200")
        .padding()
}
