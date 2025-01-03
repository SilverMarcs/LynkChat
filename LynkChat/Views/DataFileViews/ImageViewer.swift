//
//  ImageViewer.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/20/24.
//

import SwiftUI

struct ImageViewer: View {
    @ObservedObject var imageConfig = ImageModelConfig.shared
    let typedData: TypedData
    
    var body: some View {
        if let image = PlatformImage.from(data: typedData.data) {
            Image(platformImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 150, minHeight: 150)
                .roundedRectangleOverlay(radius: 8)
                .clipShape(.rect(cornerRadius: 8))
        } else {
            Text("Image Unable to Load")
                .frame(width: 150, height: 150)
                .background(Color.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 8))
        }
    }
}
