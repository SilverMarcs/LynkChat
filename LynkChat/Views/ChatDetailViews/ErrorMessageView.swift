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
        if !chat.errorMessage.isEmpty {
            VStack {
                HStack {
                    Text(chat.errorMessage)
                        .textSelection(.enabled)
                    
                    Button(role: .destructive) {
                        withAnimation {
                            chat.errorMessage = ""
                        }
                    } label: {
                        Image(systemName: "delete.backward")
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.red)
                .opacity(chat.errorMessage.isEmpty ? 0 : 1)
                .listRowSeparator(.hidden)
                .transaction { $0.animation = nil }
                
                if let last = chat.currentThread.last {
                    Button("Retry") {
                        Task { @MainActor in
                            await chat.regenerate(message: last)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                }
            }
        }
    }
}

#Preview {
    ErrorMessageView(chat: .mockChat)
}
