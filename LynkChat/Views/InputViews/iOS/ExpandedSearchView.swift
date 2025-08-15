//
//  ExpandedSearchView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 14/08/2025.
//

import SwiftUI

struct ExpandedSearchView: View {
    @Bindable var chat: Chat
    @Binding var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: FocusedField?
    
    var body: some View {
        NavigationStack{
            Form {
                TextField("Ask Anything", text: $chat.inputManager.prompt, axis: .vertical)
                    .focused($isFocused, equals: .expandedTextEditor)
            }
            .contentMargins(.top, 10)
            .navigationTitle("Prompt")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        sendInput()
                    } label: {
                        Label("Send", systemImage: "arrow.up")
                    }
                    .disabled(chat.inputManager.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            
        }
        .onAppear {
            isFocused = .expandedTextEditor
        }
    }
    
    private func sendInput() {
        isSearchFocused = false
        dismiss()
        Task {
            await chat.sendInput()
        }
    }
}
