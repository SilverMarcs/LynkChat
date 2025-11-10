//
//  UserMessage.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import TipKit

struct UserMessage: View {
    @Environment(\.chat) var chat
    
    var group: MessageGroup
    @State var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if !group.dataFiles.isEmpty {
                DataFilesView(dataFiles: group.dataFiles)
            }
            
            Group {
                #if os(macOS)
                ExpandableText(text: group.content)
                #else
                Text(group.content)
                #endif
            }
            .padding(12)
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            if group.allMessages.count > 1 {
                NavigationButtons(message: group)
            }
            
            if chat.inputManager.editingMessage == self.group.activeMessage {
                Text("Editing")
                    .font(.caption)
                    .foregroundStyle(.accent)
            }
        }
        .contentShape(.rect)
        .transaction { $0.animation = nil }
        .frame(maxWidth: .infinity, alignment: .trailing)
        #if os(macOS)
        .contentShape(.rect)
        #else
        .contentShape(.contextMenuPreview, .rect(cornerRadius: 16))
        #endif
        .contextMenu {
            MessageContextMenu(group: group) {
                showingTextSelection.toggle()
            }
        }
        .padding(.leading, leadingPadding)
        #if !os(macOS)
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: group.content)
        }
        #endif
    }
    
    var leadingPadding: CGFloat {
        #if os(macOS)
        160
        #else
        60
        #endif
    }
}
