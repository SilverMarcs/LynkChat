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
                
                // Model icons for all messages except the currently active one
                if message.role == .assistant {
                    FlowLayout(spacing: 0) {
                        ForEach(message.allMessages) { msg in
                            if msg != message.activeMessage {
                                Image(msg.model.imageName)
                                    .foregroundStyle(.white)
                                    .frame(width: 16, height: 16)
                                    .background(
                                        Circle()
                                            .fill(Color(hex: msg.model.color).gradient)
                                            .frame(width: 20, height: 20)
                                    )
                                    .opacity(0.8)
                            }
                        }

                    }
                }
            }
            .buttonStyle(.glass)
            .labelStyle(.iconOnly)
        }
    }
}
