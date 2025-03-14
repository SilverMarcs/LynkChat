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
            Image(systemName: isStop ? "stop.circle.fill" : "arrow.up.circle.fill")
                .font(.title).fontWeight(.semibold)
//                .font(.system(size: 20, weight: .regular))
        }
        .foregroundStyle((isStop ? AnyShapeStyle(.background) : AnyShapeStyle(.white)), (isStop ? .red : .accentColor))
        .opacity(0.85)
        .buttonStyle(.plain)
        .contentTransition(.symbolEffect(.replace, options: .speed(2)))
        .keyboardShortcut(isStop ? "d" : .return)
    }
}
