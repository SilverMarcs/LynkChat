//
//  MessageGroupList.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/11/2024.
//

import SwiftUI
import SwiftData

struct MessageGroupList: View {
    @Query var messageGroups: [MessageGroup]
    @Query var chats: [Chat]
    
    var searchText: String
    @State private var selectedGroupID: MessageGroup.ID?
    
    @Environment(ChatVM.self) var chatVM
    
    private var matchedGroupsByChat: [Chat: [MessageGroup]] {
        guard !searchText.isEmpty else { return [:] }
        
        var result: [Chat: [MessageGroup]] = [:]
        
        for chat in chats {
            // Filter message groups from chat.currentThread that match the search text
            let matchingGroups = chat.currentThread.filter { group in
                group.activeMessage.content.localizedStandardContains(searchText)
            }
            
            if !matchingGroups.isEmpty {
                result[chat] = matchingGroups
            }
        }
        
        return result
    }
    
    var body: some View {
        List {
            ForEach(matchedGroupsByChat.keys.sorted(by: { $0.date > $1.date }), id: \.self) { chat in
                Section {
                    ForEach(matchedGroupsByChat[chat]?.sorted(by: { $0.date < $1.date }) ?? []) { group in
                        Button {
                            let delay = chatVM.activeChat == chat ? 0 : 0.2
                            
                            chatVM.selections = [chat]
                            selectedGroupID = group.id
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                Scroller.scroll(to: .top, of: group)
                            }
                        } label: {
                            HighlightableTextView(getContextAroundMatch(content: group.activeMessage.content, searchText: searchText), highlightedText: searchText)
                                .font(.system(size: 13))
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .opacity(0.8)
                                .contentShape(Rectangle())
                        }
                        .padding(.horizontal, -4)
                        .buttonStyle(SelectedButtonStyle(isSelected: Binding(
                            get: { selectedGroupID == group.id },
                            set: { _ in }
                        )))
                    }
                } header: {
                    HStack {
                        Image(systemName: chat.status.systemImageName)
                        Text(chat.title)
                    }
                }
                
                Divider()
                    .frame(height: 1)
                    .listRowInsets(.init(top: -5, leading: 0, bottom: -10, trailing: 0))
            }
        }
    }
    
    init(searchText: String) {
        self.searchText = searchText
    }
    
    private func getContextAroundMatch(content: String, searchText: String) -> String {
        let limit = 80
        let ellipsis = "..."
        
        // First, normalize the content by replacing newlines with spaces and removing excess whitespace
        let normalizedContent = content.replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        guard !searchText.isEmpty else {
            let truncated = String(normalizedContent.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines)
            return normalizedContent.count > limit ? ellipsis + truncated + ellipsis : truncated
        }
        
        if let range = normalizedContent.range(of: searchText, options: .caseInsensitive) {
            let matchLength = min(searchText.count, limit)
            let remainingLength = limit - matchLength
            
            let preMatchStart = normalizedContent.index(range.lowerBound, offsetBy: -remainingLength/2, limitedBy: normalizedContent.startIndex) ?? normalizedContent.startIndex
            let postMatchEnd = normalizedContent.index(range.lowerBound, offsetBy: matchLength + remainingLength/2, limitedBy: normalizedContent.endIndex) ?? normalizedContent.endIndex
            
            var result = String(normalizedContent[preMatchStart..<postMatchEnd])
            
            if result.count > limit {
                result = String(result.prefix(limit))
            }
            
            result = result.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let needsLeadingEllipsis = preMatchStart > normalizedContent.startIndex
            let needsTrailingEllipsis = postMatchEnd < normalizedContent.endIndex
            
            if needsLeadingEllipsis {
                result = ellipsis + result
            }
            if needsTrailingEllipsis {
                result = result + ellipsis
            }
            
            return result
        } else {
            let truncated = String(normalizedContent.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines)
            return normalizedContent.count > limit ? ellipsis + truncated + ellipsis : truncated
        }
    }
}

struct SelectedButtonStyle: ButtonStyle {
    @Binding var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(5)
            .background(isSelected || configuration.isPressed ? .accent.opacity(0.3) : .clear)
            .cornerRadius(5)
    }
}

extension ButtonStyle where Self == SelectedButtonStyle {
    static func selected(_ isSelected: Binding<Bool>) -> SelectedButtonStyle {
        SelectedButtonStyle(isSelected: isSelected)
    }
}

