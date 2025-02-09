//
//  TranscriptionView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct TranscriptionView: View {
    var content: String?
    
    var body: some View {            
            GroupBox {
                Text(content ?? String.mockTranscription)
                    .shimmer(when: content == nil)
                    .textSelection(.enabled)
                    .padding(3)
                    .transition(.opacity)
            }
            .groupBoxStyle(PlatformGroupBoxStyle())
            .animation(.easeIn, value: content != nil) // Add animation
//        }
    }
}

#Preview {
    TranscriptionView()
}
