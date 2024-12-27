//
//  RegenButton.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI
import SwiftData

struct RegenButton: View {
    var group: MessageGroup
    
    var body: some View {
        Button {
            Task {
                await group.chat?.regenerate(message: group)
            }
        } label: {
            Label("Regenerate", systemImage: "arrow.2.circlepath")
        }
    }
}
