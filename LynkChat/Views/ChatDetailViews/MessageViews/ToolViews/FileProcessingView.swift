//
//  FileProcessingView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct FileProcessingView: View {
    var content: String?
    
    var body: some View {
        GroupBox {
            Text(content ?? String.mockTranscription)
                .shimmer(when: content == nil)
                .textSelection(.enabled)
                .transition(.opacity)
        }
        .groupBoxStyle(PlatformGroupBox())
        .animation(.easeIn, value: content != nil) // Add animation
    }
}

#Preview {
    FileProcessingView()
}
