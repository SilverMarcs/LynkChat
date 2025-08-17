//
//  AssistantMessage.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct AssistantMessage: View {
    @ObservedObject var config = AppConfig.shared
    var message: Message
    var group: MessageGroup
    var showMenu: Bool = true
    
    @State var height: CGFloat = 0
    @State private var showingTextSelection = false
    @Namespace private var transition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AssistantLabel(model: message.model)
            #if os(macOS)
                .padding(.leading, -25)
            #endif
            
            if let tools = message.tools, !tools.isEmpty {
                ChatToolView(tools: tools)
            }
            
            if let reason = message.reasoning, !reason.isEmpty {
                ReasoningView(reason: reason)
            }
            
            MDView(content: message.content, calculatedHeight: $height)
                .transaction { $0.animation = nil }
                #if os(macOS)
                .frame(height: message.height, alignment: .top)
                .onChange(of: height) {
                    if height > 0 {
                        message.height = height
                    }
                }
                #else
                .padding(.leading, 5)
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
            
            if !message.isReplying {
                if !showMenu {
                    SecondaryNavigationButtons(group: group)
                } else {
                    if group.allMessages.count > 1 {
                        NavigationButtons(message: group)
                    }
                }
            }
        }
        .transaction { $0.animation = nil }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contextMenu {
            MessageContextMenu(group: group) {
                showingTextSelection.toggle()
            }
        }
        .matchedTransitionSource(id: "assistant-text-selection", in: transition)
        .padding(.leading, 26)
        .padding(.trailing, 30)
        #if !os(macOS)
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: group.content)
                .navigationTransition(.zoom(sourceID: "assistant-text-selection", in: transition))
        }
        #endif
    }
}

#Preview {
    AssistantMessage(message: .mockAssistantMessage, group: .mockAssistantGroup)
        .frame(width: 600, height: 300)
}
