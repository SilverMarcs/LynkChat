//
//  ImageViewer.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/20/24.
//

import SwiftUI

struct ImageViewer: View {
    let typedData: TypedData
    
    var body: some View {
        if let image = PlatformImage.from(data: typedData.data) {
            Image(platformImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: size , maxHeight: size)
                .roundedRectangleOverlay(radius: 8)
                .clipShape(.rect(cornerRadius: 8))
        } else {
            Text("Image Unable to Load")
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 8))
        }
    }
    
    var size: CGFloat {
        #if os(macOS)
        100
        #else
        75
        #endif
    }
}
