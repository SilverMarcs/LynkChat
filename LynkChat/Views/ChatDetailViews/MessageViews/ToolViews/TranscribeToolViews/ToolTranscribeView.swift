//
//  ToolTranscribeView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolTranscribeView: View {
    let transcription: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Transcription")
                .font(.headline)
            
            Text(transcription)
        }
    }
}

#Preview {
    ToolTranscribeView(transcription: .mockTranscription)
}
