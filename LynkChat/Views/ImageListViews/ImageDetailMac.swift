//
//  ImageDetailMac.swift
//  LynkChat
//
//  Created by Codex on 30/10/2025.
//

import SwiftUI

struct ImageDetail: View {
    @Bindable var session: ImageSession

    var body: some View {
        ImageGridView(generations: session.imageGenerations)
        .contentMargins(.all, 15, for: .scrollContent)
        .navigationTitle(session.title)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Delete Last Message", role: .destructive) {
                    if let last = session.imageGenerations.last {
                        session.deleteGeneration(last)
                    }
                }
                .keyboardShortcut(.delete)
            }
        }
        .safeAreaBar(edge: .bottom) {
            ImageInputView(session: session)
        }
    }
}
