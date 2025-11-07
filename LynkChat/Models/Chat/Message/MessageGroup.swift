//
//  MessageGroup.swift
//  LynkChat
//
//  Created by Zabir Raihan on 22/11/2024.
//

import SwiftData
import SwiftUI

@Model
final class MessageGroup: Hashable, Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    
    @Relationship(deleteRule: .cascade)
    var rootMessage: Message?
    
    @Relationship(deleteRule: .cascade)
    var activeMessage: Message
    
    @Relationship(deleteRule: .cascade)
    var allUnorderedMessages: [Message] = []
    var allMessages: [Message] {
        get {
            allUnorderedMessages.sorted(by: { $0.date < $1.date })
        }
        set {
            allUnorderedMessages = newValue
        }
    }
    
    init(message: Message) {
        self.allUnorderedMessages = [message]
        self.activeMessage = message
    }
    
    func addMessage(_ message: Message, skipActive: Bool = false) {
        if message.role == .assistant {
            message.isReplying = true
        }
        allMessages.append(message)
        if !skipActive {
            activeMessage = message
        }
    }
    
    func copy() -> MessageGroup {
        return MessageGroup(message: activeMessage.copy())
    }
    
    // MARK: - computed message properties
    // TODO: dont really need all these props since we can just use the activeMessage directly and we shudnt expose all these props
    var model: ChatModel {
        activeMessage.model
    }
    
    var content: String {
        activeMessage.content
    }

    var dataFiles: [TypedData] {
        activeMessage.dataFiles
    }
    
    var role: Message.Role {
        activeMessage.role
    }
    
    var isReplying: Bool {
        activeMessage.isReplying
    }
    
    // MARK: - Active Message Navigation
    var currentMessageIndex: Int {
        allMessages.firstIndex(of: activeMessage) ?? 0
    }
    
    var canGoToPrevious: Bool {
        currentMessageIndex > 0
    }
    
    var canGoToNext: Bool {
        currentMessageIndex < allMessages.count - 1
    }
    
    func goToPreviousMessage() {
        guard canGoToPrevious else { return }
        activeMessage = allMessages[currentMessageIndex - 1]
    }
    
    func goToNextMessage() {
        guard canGoToNext else { return }
        activeMessage = allMessages[currentMessageIndex + 1]
    }
    
    func deleteActiveMessage() {
        guard allMessages.count > 1, let index = allMessages.firstIndex(of: activeMessage) else { return }
        
        allUnorderedMessages.removeAll { $0 == activeMessage }
        
        let nextIndex = min(index, allMessages.count - 1)
        activeMessage = allMessages[nextIndex]
    }
    
    func deleteAndSetPreviousActive() {
        let currentIndex = allMessages.firstIndex(of: activeMessage)!
        activeMessage = allMessages[currentIndex - 1]
        allUnorderedMessages.removeAll { $0 == allMessages[currentIndex] }
    }
    
    // MARK: - Secondary Message Navigation
    @Attribute(.ephemeral)
    var isSplitView: Bool = false
    @Attribute(.ephemeral)
    var secondaryMessageIndex: Int = 0
    
    var secondaryMessages: [Message] {
        allMessages.filter { $0 != activeMessage }
    }
    
    func toggleSplitView() {
        isSplitView.toggle()
        if isSplitView {
            secondaryMessageIndex = 0
        }
    }
    
    func nextSecondaryMessage() {
        guard secondaryMessageIndex < secondaryMessages.count - 1 else { return }
        secondaryMessageIndex += 1
    }
    
    func previousSecondaryMessage() {
        guard secondaryMessageIndex > 0 else { return }
        secondaryMessageIndex -= 1
    }
    
    var canGoToNextSecondary: Bool {
        secondaryMessageIndex < secondaryMessages.count - 1
    }
    
    var canGoToPreviousSecondary: Bool {
        secondaryMessageIndex > 0
    }
}
