//
//  AssistantMessage.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct AssistantMessage: View {
    var message: Message
    var group: MessageGroup
    var showMenu: Bool = true
    
    @State private var height: CGFloat = 0
    @State private var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AssistantLabel(model: message.model)
            
            VStack(alignment: .leading, spacing: 8) {
                if let tools = message.tools, !tools.isEmpty {
                    ChatToolView(tools: tools)
                }
                
                if let reason = message.reasoning, !reason.isEmpty {
                    ReasoningView(reason: reason)
                }
            
                MDView(
                    content: message.content,
                    isStreaming: message.isReplying,
                    calculatedHeight: $height
                )
                    .transaction { $0.animation = nil }
                    #if os(macOS)
//                    .frame(height: message.height, alignment: .top)
//                    .onChange(of: height) {
//                        if height > 0 {
//                            message.height = height
//                        }
//                    }
                    .frame(height: message.height > 0 ? message.height : nil, alignment: .top)
                    .onChange(of: height) { _, newHeight in
                        guard newHeight > 0, message.height != newHeight else { return }
                        message.height = newHeight
                    }
                    #endif
                
                if !message.dataFiles.isEmpty {
                    ForEach(message.dataFiles, id: \.self) { data in
                        ImageViewerData(data: data.data)
                    }
                }
                
                if message.isReplying {
                    ProgressView()
                        .controlSize(.small)
                }
                
//                if !message.isReplying {
                    if !showMenu {
                        SecondaryNavigationButtons(group: group)
                    } else {
                        if group.allMessages.count > 1 {
                            NavigationButtons(message: group)
                        }
                    }
//                }
            }
            .padding(.leading, 25)
        }
        .contentShape(.rect)
        .transaction { $0.animation = nil }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contextMenu {
            MessageContextMenu(group: group) {
                showingTextSelection.toggle()
            }
        } preview: {
            VStack(alignment: .leading, spacing: 8) {
                AssistantLabel(model: message.model)
                NativeMarkdownView(text: String(message.content.prefix(800)))
            }
            .padding()
            .frame(maxWidth: 500)
        }
        .padding(.leading, 5)
        .padding(.trailing, 30)
        #if !os(macOS)
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: group.content)
        }
        #endif
    }
}

#Preview {
    AssistantMessage(message: .mockAssistantMessage, group: .mockAssistantGroup)
        .frame(width: 600, height: 300)
}
