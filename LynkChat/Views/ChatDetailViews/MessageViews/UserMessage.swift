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
    @Environment(\.searchText) var searchText
    @Environment(\.colorScheme) var colorScheme
    @Environment(ChatVM.self) private var chatVM
    
    @ObservedObject var config = AppConfig.shared
    
    var group: MessageGroup

    @State var isExpanded: Bool = false
    @State var showingTextSelection = false
    @State var height: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if !group.dataFiles.isEmpty {
                DataFilesView(dataFiles: group.dataFiles)
                    .transaction { $0.animation = nil }
            }
            
            GroupBox {
                VStack(alignment: .leading, spacing: 0) {
                    if searchText.isEmpty {
                        HighlightableTextView(displayedText, highlightedText: chatVM.searchText)
    //                        .textSelection(.enabled)
                            .font(.system(size: config.fontSize))
                            #if os(macOS)
                            .lineSpacing(2)
                            .padding(5)
                            #endif
                    } else {
                        MDView(content: displayedText)
                    }

//                    AutoHeightTextView(text: displayedText, height: $textViewHeight)
//                        .frame(height: group.activeMessage.height, alignment: .top)
//                         .onChange(of: textViewHeight) {
//                             DispatchQueue.main.async {
//                                 group.activeMessage.height = textViewHeight
//                             }
//                         }
                    
                    if shouldShowMoreButton {
                        Button {
                            isExpanded.toggle()
                            if !isExpanded {
                                Scroller.scroll(to: .top, of: group)
                            }
                        } label: {
                            Text(isExpanded ? "Less" : "More")
                                .font(.callout)
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 4)
                        .padding(.bottom, 2)
                    }
                }
            }
            .transaction { $0.animation = nil }
            .groupBoxStyle(PlatformGroupBoxStyle())
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(chat.inputManager.editingMessage == self.group.activeMessage ? Color.accentColor.opacity(0.2) : .clear)
            )
            
            #if os(macOS)
            if group.allMessages.count > 1 {
                NavigationButtons(message: group)
            }
            #endif
        }
        .padding(.leading, leadingPadding)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: group.content)
        }
        .contextMenu {
            MessageMenu(group: group) {
                showingTextSelection.toggle()
            }
        }
    }
    
    var leadingPadding: CGFloat {
        #if os(macOS)
        160
        #else
        60
        #endif
    }
    
    private var displayedText: String {
        let maxCharacters = 400
        if isExpanded || !chatVM.searchText.isEmpty {
            return group.content
        } else {
            return String(group.content.prefix(maxCharacters))
        }
    }

    private var shouldShowMoreButton: Bool {
        group.content.count > 400 && chatVM.searchText.isEmpty
    }
}

#Preview {
    UserMessage(group: .mockUserGroup)
        .frame(width: 500, height: 300)
}
