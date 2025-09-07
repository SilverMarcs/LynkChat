//
//  AudioServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/09/2025.
//

import SwiftUI

struct AudioServiceSettings: View {
    @ObservedObject var config: AppConfig = .shared
    
    var body: some View {
        Form {
            TextField("Enter Gemini API Key", text: $config.geminiApiKey)
        }
        .formStyle(.grouped)
        .navigationTitle("Audio Service")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    AudioServiceSettings()
}
