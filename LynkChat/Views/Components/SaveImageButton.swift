//
//  SaveImageButton.swift
//  LynkChat
//
//  Created by Codex on 27/10/2025.
//

import SwiftUI

struct SaveImageButton: View {
    let data: Data?
    
    @State private var showCheckmark = false
    
    var body: some View {
        Button(action: saveImage) {
            Image(systemName: showCheckmark ? "checkmark" : "square.and.arrow.down")
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.extraLarge)
    }
    
    private func saveImage() {
        guard let data else { return }
        ImageSaveUtil.saveImage(data: data) { success in
            if success {
                DispatchQueue.main.async {
                    showCheckmark = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showCheckmark = false
                    }
                }
            }
        }
    }
}

