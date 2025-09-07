//
//  ChatListCards.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI
import TipKit

struct ChatListCards: View {
    @Environment(\.isSearching) private var isSearching
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.windowType) private var windowType

    var chatCount: String
    var imageSessionsCount: String
    
    @State private var isFlashing = false
    
    private let chatVM = ChatVM.shared

    var body: some View {
        HStack(spacing: 8) {
            ListCard(
                icon: chatVM.statusFilter.systemImageName, iconColor: chatVM.statusFilter.iconColor, title: isSearching ? "Searching" : chatVM.statusFilter.name,
                count: chatCount) {
                    handleChatPress()
                }
                .contentTransition(.symbolEffect(.replace.offUp))
                .disabled(isSearching)
            
            ListCard(
                icon: "photo.fill", iconColor: .indigo, title: "Images",
                count: imageSessionsCount) {
                    handleImagePress()
                }
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: -5))
        .padding(.bottom, 8.5)
    }
    
    func handleChatPress() {
        switch windowType {
        case .chats:
            cycleChatStatus()
        case .images:
            openWindow(id: WindowID.chats)
            dismissWindow(id: WindowID.images)
        case .audio:
            print("TBI")
        }
    }
    
    func cycleChatStatus() {
        let statusesToCycle: [ChatStatus] = ChatStatus.allCases.filter { $0 != .quick && $0 != .temporary }
        
        guard let currentStatusIndex: Int = statusesToCycle.firstIndex(of: chatVM.statusFilter) else {
            return
        }
        
        let nextStatusIndex: Int = (currentStatusIndex + 1) % statusesToCycle.count
        chatVM.statusFilter = statusesToCycle[nextStatusIndex]
    }

    
    func handleImagePress() {
        openWindow(id: WindowID.images)
        dismissWindow(id: WindowID.chats)
    }
}

#Preview {
    ChatListCards(chatCount: "5", imageSessionsCount: "?")
        .environment(\.windowType, .chats)
}
