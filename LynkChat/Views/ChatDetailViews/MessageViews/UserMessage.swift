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
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var config = AppConfig.shared
    
    var group: MessageGroup
    @State var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if chat.inputManager.editingMessage == self.group.activeMessage {
                Text("Editing")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
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
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18)
                   .fill(.background.tertiary)
                    // .fill(.accent.gradient.secondary)
                    .stroke(.quaternary, lineWidth: 1)
            )
            
            if group.allMessages.count > 1 {
                NavigationButtons(message: group)
            }
        }
        .transaction { $0.animation = nil }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .contentShape(.rect)
        .contextMenu {
            MessageContextMenu(group: group) {
                showingTextSelection.toggle()
            }
        } preview: {
            Text(group.content.prefix(200))
                .padding()
        }
        .padding(.leading, leadingPadding)
        #if !os(macOS)
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: group.content)
        }
        #endif
    }
    
    var padding: CGFloat {
        #if os(macOS)
        7
        #else
        11
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

struct ExpandableText: View {
    let text: String
    let maxCharacters: Int
    
    @State private var isExpanded = false
    private let needsExpansion: Bool
    
    init(text: String, maxCharacters: Int = 400) {
        self.text = text
        self.maxCharacters = maxCharacters
        self.needsExpansion = text.count > maxCharacters
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text(displayedText)
                .textSelection(.enabled)
                .font(.system(size: AppConfig.shared.fontSize))
                .lineSpacing(2)
                .padding(4)
            
            if needsExpansion {
                Button {
                    isExpanded.toggle()
                } label: {
                    Text(isExpanded ? "Show Less" : "Show More")
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
            }
        }
    }
    
    private var displayedText: String {
        guard needsExpansion && !isExpanded else {
            return text
        }
        return String(text.prefix(maxCharacters))
    }
}
