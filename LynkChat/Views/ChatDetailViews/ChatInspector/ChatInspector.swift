//
//  ChatInspector.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
import TipKit

struct ChatInspector: View {
    @Environment(\.dismiss) var dismiss
    var chat: Chat
    
    @State private var selectedTab: InspectorTab = .basic
    
    var body: some View {
        #if os(macOS)
        macos
            .frame(width: 400, height: 616)
        #else
        ios
        #endif
    }
    
    var macos: some View {
        BasicInspector(chat: chat)
            .overlay(alignment: .topTrailing) {
                DismissButton()
                    .padding(10)
            }

    }
    
    var ios: some View {
        NavigationStack {
            BasicInspector(chat: chat)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        DismissButton()
                    }
                }
        }
    }
}


#Preview {
    ChatInspector(chat: .mockChat)
        .frame(width: 400, height: 700)
}
