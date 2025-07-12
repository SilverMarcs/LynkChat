//
//  ErrorMessageView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct ErrorMessageView: View {
    var chat: Chat
    
    var body: some View {
        if let errorMessage = chat.errorMessage {
            HStack {
                Text(errorMessage)
                    .textSelection(.enabled)
                
                Button(role: .destructive) {
                    withAnimation {
                        chat.errorMessage = nil
                    }
                } label: {
                    Image(systemName: "delete.backward")
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.red)
            .listRowSeparator(.hidden)
            .transaction { $0.animation = nil }
        }
    }
}

#Preview {
    ErrorMessageView(chat: .mockChat)
}
