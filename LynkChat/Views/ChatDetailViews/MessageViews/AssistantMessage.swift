//
//  AssistantMessage.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct AssistantMessage: View {
    @Environment(ChatVM.self) var chatVM
    
    @ObservedObject var config = AppConfig.shared
    var message: Message
    var group: MessageGroup
    var showMenu: Bool = true
    
    @State var height: CGFloat = 0
    @State private var showingTextSelection = false
    @State private var showingReasoning = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AssistantLabel(model: message.model)
                .transaction { $0.animation = nil }
                .padding(.leading, labelPadding)
            
            if let tools = message.tools, !tools.isEmpty {
                ChatToolView(tools: tools)
            }
            
            if let reason = message.reasoning, !reason.isEmpty {
                Button {
                    showingReasoning.toggle()
                } label: {
                    Text(showingReasoning ? "Hide reasoning" : "Show reasoning")
                        .textSelection(.enabled)
                }
                
                if showingReasoning {
                    Text(reason)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, -10)
                }
            }
            
            MDView(content: message.content, calculatedHeight: $height)
                .environment(\.searchText, chatVM.searchText)
                .environment(\.isReplying, message.isReplying)
                .transaction { $0.animation = nil }
            #if os(macOS)
                .apply { view in
                    if config.isMarkdownEnabled {
                        view
                            .frame(height: message.height, alignment: .top)
                            .onChange(of: height) {
                                if height > 0 {
                                    message.height = height
                                }
                            }
                    } else {
                        view
                    }
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
            
            #if os(macOS)
            if !message.isReplying {
                if !showMenu {
                    SecondaryNavigationButtons(group: group)
                    Spacer()
                } else {
                    if group.allMessages.count > 1 {
                        NavigationButtons(message: group)
                        Spacer()
                    }
                }
            }
            #endif
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 25)
        .padding(.trailing, 30)
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: message.content)
        }
        .contextMenu {
            MessageMenu(group: group) {
                showingTextSelection.toggle()
            }
        }
    }
    
    var labelPadding: CGFloat {
        #if os(macOS)
        return -22
        #else
        return -25
        #endif
    }
}

#Preview {
    AssistantMessage(message: .mockAssistantMessage, group: .mockAssistantGroup)
        .environment(ChatVM())
        .frame(width: 600, height: 300)
}
