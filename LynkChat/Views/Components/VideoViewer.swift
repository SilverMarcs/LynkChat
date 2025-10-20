//
//  VideoViewer.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/10/2025.
//

import SwiftUI
import SwiftMediaViewer

struct VideoViewer: View {
    let url: URL
    var enableSave: Bool = true
    var size: CGFloat = 300
    
    @State private var selectedFileURL: URL?
    @State private var showCheckmark = false
    
    var body: some View {
        HStack {
            SMVVideo(videoURL: url.absoluteString)
                .aspectRatio(9/16, contentMode: .fit)
                .frame(maxWidth: size)
                .clipShape(.rect(cornerRadius: 10))
            
            if enableSave {
                Button(action: saveVideo) {
                    Image(systemName: showCheckmark ? "checkmark" : "arrow.down")
                        .frame(width: 12, height: 12)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.extraLarge)
                .padding(10)
            }
        }
    }

    func saveVideo() {
        VideoSaveUtil.saveVideoFromURL(url: url) { success in
            if success {
                DispatchQueue.main.async {
                    showCheckmark = true
                    
                    // Revert back to the original icon after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showCheckmark = false
                    }
                }
            }
        }
    }
}
