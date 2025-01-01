//
//  RegenButton.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI
import SwiftData

struct RegenButton: View {
    var regen: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await regen()
            }
        } label: {
            Label("Regenerate", systemImage: "arrow.2.circlepath")
        }
    }
}
