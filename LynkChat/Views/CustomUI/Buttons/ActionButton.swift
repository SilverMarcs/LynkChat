//
//  ActionButton.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/14/24.
//

import SwiftUI

struct ActionButton: View {
    var isStop: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isStop ? "stop" : "arrow.up")
                .font(.system(size: 15)).fontWeight(.semibold)
//                .foregroundStyle(.white, .clear)
//                .glassEffect(.regular.tint(isStop ? .red : .accentColor))
//                .font(.system(size: 20, weight: .regular))
        }
        .opacity(0.85)
        .controlSize(.large)
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .keyboardShortcut(isStop ? "d" : .return)
    }
}


#Preview {
    ActionButton(isStop: false, action: {})
        .padding()
}
