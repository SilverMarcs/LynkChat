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
    @Namespace private var transition
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if !group.dataFiles.isEmpty {
                DataFilesView(dataFiles: group.dataFiles)
            }
            
            GroupBox {
                #if os(macOS)
                ExpandableText(text: group.content)
                #else
                Text(group.content)
                #endif
            }
            .groupBoxStyle(PlatformGroupBox())
            .matchedTransitionSource(id: "text-selection", in: transition)

            if group.allMessages.count > 1 {
                NavigationButtons(message: group)
            }
            
            if chat.inputManager.editingMessage == self.group.activeMessage {
                Text("Editing")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
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
                .navigationTransition(.zoom(sourceID: "text-selection", in: transition))
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

struct ExpandableText: View {
    let text: String
    let maxCharacters: Int
    
    @State private var isExpanded = false
    private let needsExpansion: Bool
    
    @ObservedObject var config = AppConfig.shared
    
    init(text: String, maxCharacters: Int = 400) {
        self.text = text
        self.maxCharacters = maxCharacters
        self.needsExpansion = text.count > maxCharacters
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 3) {
            Text(displayedText)
                .textSelection(.enabled)
                .font(.system(size: config.fontSize))
                .lineSpacing(2)
            
            if needsExpansion {
                Button {
                    isExpanded.toggle()
                } label: {
                    Text(isExpanded ? "Show Less" : "Show More")
                }
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



