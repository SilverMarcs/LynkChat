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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AssistantLabel(model: message.model)
                .padding(.leading, -25)
            
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
            MessageMenu(group: group) {
                showingTextSelection.toggle()
            }
        } preview: {
            Text(group.content.prefix(200))
                .padding()
        }
        .padding(.leading, 26)
        .padding(.trailing, 30)
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: message.content)
        }
    }
}

#Preview {
    AssistantMessage(message: .mockAssistantMessage, group: .mockAssistantGroup)
        .frame(width: 600, height: 300)
}
