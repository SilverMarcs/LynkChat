//
//  ChatListRow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct ChatListRow: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.openWindow) var openWindow
    @Environment(ChatVM.self) private var chatVM
    
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat

    var body: some View {
        row
        .swipeActions(edge: .leading) {
            swipeActionsLeading
        }
        .swipeActions(edge: .trailing) {
            swipeActionsTrailing
        }
        .contextMenu {
            Button {
                Task {
                    let newChat = await chat.copy()
                    newChat.title = "(Ψ) " + newChat.title
                    chatVM.fork(newChat: newChat)
                }
            } label: {
                Label("Fork Chat", systemImage: "arrow.branch")
                    .labelStyle(.titleAndIcon)
            }
        }
    }
    
    var row: some View {
        HStack {
            ListRowImage(model: chat.config.model)
            
            HighlightableTextView(chat.title, highlightedText: chatVM.searchText)
                .lineLimit(1)
                .font(font)
                .opacity(0.9)
                .shimmerWithoutRedact(when: chat.isReplying)
            
            Spacer()
            
            chatStatusMarker
                .imageScale(.small)
                .transition(.symbolEffect(.appear))
            
//            Text(chat.config.model.name)
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//                .fontWidth(.compressed)
        }
        .padding(padding)
//        defaultMinListRowHeight()
    }
    
    var font: Font {
        #if os(macOS)
        return .headline.weight(.regular)
        #else
        return .headline.weight(.medium)
        #endif
    }
    
    var padding: CGFloat {
        #if os(macOS)
        return 3
        #else
        return 4
        #endif
    }
    
    @ViewBuilder
    var chatStatusMarker: some View {
        switch chat.status {
        case .starred:
            Image(systemName: "star.fill")
                .foregroundStyle(.orange)
        case .archived:
            Image(systemName: "archivebox.fill")
                .foregroundStyle(.gray)
        case .quick:
            Image(systemName: "bolt.fill")
                .foregroundStyle(.yellow)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    var swipeActionsLeading: some View {
        if chat.status != .starred {
            Button {
                SwipeActionTip().invalidate(reason: .actionPerformed)
                
                if chatVM.selections.contains(chat) {
                    chatVM.selections.remove(chat)
                }
                
                chat.status = (chat.status == .archived) ? .normal : .archived
            } label: {
                Label("Archive", systemImage: chat.status == .archived ? "tray.and.arrow.up.fill" : "archivebox")
            }
            .tint(chat.status == .archived ? .blue : .gray)
        }
        
        if chat.status != .archived {
            Button {
                SwipeActionTip().invalidate(reason: .actionPerformed)
                chat.status = chat.status == .starred ? .normal : .starred
            } label: {
                Label(chat.status == .starred ? "Unstar" : "Star", systemImage: chat.status == .starred ? "star.slash" : "star")
            }
            .tint(.orange)
        }
    }
    
    @ViewBuilder
    var swipeActionsTrailing: some View {
        if chat.status != .starred {
            Button(role: .destructive) {
                SwipeActionTip().invalidate(reason: .actionPerformed)

                if chatVM.selections.contains(chat) {
                    chatVM.selections.remove(chat)
                }
                
                modelContext.delete(chat)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

#Preview {
    List {
        ChatListRow(chat: .mockChat)
            .environment(ChatVM())
    }
    .frame(width: 250)
}
