//
//  ImageViewerData.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/09/2024.
//

import SwiftUI
import Photos
import SwiftMediaViewer

struct ImageViewerData: View {
    let data: Data
    var enableSave: Bool = true
    var size: CGFloat = 300
    
    var body: some View {
        SMVImageData(data: data)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(.rect(cornerRadius: 10))
    }
}
