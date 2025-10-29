//
//  AudioServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/09/2025.
//

import SwiftUI

struct AudioServiceSettings: View {
    @AppStorage("geminiApiKey") var geminiApiKey: String = ""
    
    var body: some View {
        Form {
            TextField("Gemini API Key", text: $geminiApiKey)
        }
        .formStyle(.grouped)
        .navigationTitle("Audio Service")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    AudioServiceSettings()
}
