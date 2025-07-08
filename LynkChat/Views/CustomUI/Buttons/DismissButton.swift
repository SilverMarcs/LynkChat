//
//  DismissButton.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/07/2024.
//

import SwiftUI

struct DismissButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(role: .close) {
            dismiss()
        } label: {
            Image(systemName: "xmark")
        }
        .controlSize(.large)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
    }
}

#Preview {
    DismissButton()
}
