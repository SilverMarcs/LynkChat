//
//  ToolTranscribePlaceholderView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolTranscribePlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Transcription")
                .font(.headline)
            
            Text(String.mockTranscription)
        }
        .shimmer(when: true)
    }
}

#Preview {
    ToolTranscribePlaceholderView()
}
