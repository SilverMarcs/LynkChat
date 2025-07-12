//
//  NavigationButtons.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct NavigationButtons: View {
    var message: MessageGroup
    
    var body: some View {
        if message.allMessages.count > 1 {
            HStack {
                #if os(macOS)
                if message.allMessages.count >= 2 && message.role == .assistant {
                    ControlGroup {
                        Button {
                            message.toggleSplitView()
                        } label: {
                            Label(message.isSplitView ? "Exit SplitView" : "SplitView", systemImage: message.isSplitView ? "rectangle.split.2x1.slash" : "square.split.2x1")
                                
                        }
                    }
                }
                
                Text("\(message.currentMessageIndex + 1)/\(message.allMessages.count)")
                    .foregroundColor(.secondary)
                #endif
                
                ControlGroup {
                    if !message.isSplitView {
                        Button {
                            message.goToPreviousMessage()
                        } label: {
                            Label("Previous", systemImage: "chevron.left")
                        }
                        .disabled(!message.canGoToPrevious)
                        
                                 
                        
                        Button {
                            message.goToNextMessage()
                        } label: {
                            Label("Next", systemImage: "chevron.right")
                        }
                        .disabled(!message.canGoToNext)
                    }
                }
                .controlGroupStyle(.navigation)
            }
            .buttonStyle(.glass)
            .labelStyle(.iconOnly)
        }
    }
}
