//
//  Chat.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftData
import SwiftUI

@Model
final class Chat: Equatable, Identifiable, Hashable {
    var id: UUID = UUID()
    var date: Date = Date()
    var title: String = "New Chat Session"
    var errorMessage: String? = nil
    
    var statusId: Int = 1 // normal status
    var status: ChatStatus {
        get { ChatStatus(rawValue: statusId)! }
        set { statusId = newValue.id }
    }
    
    @Relationship(deleteRule: .nullify)
    var contextResetPoint: MessageGroup?
    var adjustedContext: [Message] {
        guard let resetPoint = contextResetPoint,
              let resetIndex = currentThread.firstIndex(of: resetPoint),
              resetIndex + 1 < currentThread.count else {
            return currentThread.map { $0.activeMessage }
        }

        return currentThread[(resetIndex + 1)...].map { $0.activeMessage }
    }

    @Relationship(deleteRule: .cascade)
    var rootMessage: MessageGroup?
    var currentThread: [MessageGroup] {
        var thread: [MessageGroup] = []
        var currentGroup = rootMessage
        
        while let group = currentGroup {
            thread.append(group)
            currentGroup = group.activeMessage.next
        }
        
        return thread
    }
    var isEmpty: Bool = true
    
    @Relationship(deleteRule: .cascade)
    var config: ChatConfig = ChatConfig()
    
    @Transient
    var streamingTask: Task<Void, Error>?
    
    var isReplying: Bool {
        currentThread.last?.isReplying ?? false
    }

    @Transient
    var inputManager = InputManager()
    
    
    var totalTokens: Int {
        adjustedContext.reduce(0) { total, message in
            total + message.inputTokens + message.outputTokens + message.reasoningTokens
        }
    }
    
    init() { }
    
    @MainActor
    func processRequest(message: Message, user: Message) async {
        streamingTask?.cancel()
        if let task = streamingTask {
            try? await task.value
        }
        
        errorMessage = nil
        date = Date()
        streamingTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let handler = StreamHandler(chat: self, assistant: message, user: user)
                try await handler.handleRequest()
                
                #if !os(macOS)
                let backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
                    self?.streamingTask?.cancel()
                }

//                defer {
                    UIApplication.shared.endBackgroundTask(backgroundTaskId)
//                }
                #endif
            } catch {
                handleError(error)
            }
            
            streamingTask?.cancel()
            streamingTask = nil
        }
        
        if AppConfig().autogenTitle {
            Task { [weak self] in
                await self?.generateTitle()
            }
        }
    }

    @MainActor
    func editMessage(_ message: Message) async {
        guard let userGroup = currentThread.first(where: { $0.activeMessage == message }) else { return }
        
        unsetContextResetPointIfNeeded(for: userGroup)
        
        let newUserMessage = Message.user(content: inputManager.prompt, dataFiles: inputManager.dataFiles)
        userGroup.addMessage(newUserMessage)
        
        let newAssistantMessage = Message.assistant(model: config.model)
        let newAssistantGroup = MessageGroup(message: newAssistantMessage)
        
        newUserMessage.next = newAssistantGroup
         
        await processRequest(message: newAssistantMessage, user: newUserMessage)
    }
    

    @MainActor
    func sendInput(prompt: String? = nil) async {
        if rootMessage == nil {
            withAnimation { isEmpty = false }
        }
        
        var content: String
        if let prompt = prompt {
            content = prompt
        } else {
            content = inputManager.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        guard !content.isEmpty else {
            return
        }
        
        errorMessage = nil
        
        if let editingMessage = inputManager.editingMessage {
            await editMessage(editingMessage)
        } else {
            let userMessage = Message.user(
                content: content,
                dataFiles: inputManager.dataFiles
            )
            let userGroup = MessageGroup(message: userMessage)
            
            if rootMessage == nil {
                rootMessage = userGroup
            } else {
                let lastGroup = currentThread.last!
                lastGroup.activeMessage.next = userGroup
            }
            
            let assistantMessage = Message.assistant(model: config.model)
            let assistantGroup = MessageGroup(message: assistantMessage)
            userGroup.activeMessage.next = assistantGroup
             
            await processRequest(message: assistantMessage, user: userMessage)
        }
        
        // Reset inputManager after everything is done
        inputManager.reset()
    }

    @MainActor
    func regenerate(message: MessageGroup) async {
        guard let index = currentThread.firstIndex(where: { $0 == message }) else { return }
       
        unsetContextResetPointIfNeeded(for: message)
       
        if message.role == .assistant {
            let newAssistantMessage = Message.assistant(model: config.model)
            message.addMessage(newAssistantMessage)
            message.activeMessage.next = nil
           
            await processRequest(message: newAssistantMessage, user: currentThread[index - 1].activeMessage)
        } else if message.role == .user {
            if index + 1 < currentThread.count {
                let assistantGroup = currentThread[index + 1]
                let newAssistantMessage = Message.assistant(model: config.model)
                assistantGroup.addMessage(newAssistantMessage)
                assistantGroup.activeMessage.next = nil
               
                await processRequest(message: newAssistantMessage, user: message.activeMessage)
            } else {
                let assistantMessage = Message.assistant(model: config.model)
                let assistantGroup = MessageGroup(message: assistantMessage)
                message.activeMessage.next = assistantGroup
                
                await processRequest(message: assistantMessage, user: message.activeMessage)
            }
        }
    }
    
    @MainActor
    func stopStreaming() {
        guard let task = streamingTask else { return }
        task.cancel()
        streamingTask = nil
        
        // Ensure the message is in a clean state before allowing new queries
        if let lastGroup = currentThread.last {
            lastGroup.activeMessage.isReplying = false
            
            // Stop all messages in the group from replying
            for message in lastGroup.allMessages {
                message.isReplying = false
            }
        }
        
        errorDeleteLast()
        withAnimation(.easeInOut(duration: 0.5)) {
            AppSettings.shared.expandColor = false
        }
    }

    @MainActor
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription.isEmpty ? "An unknown error occurred" : error.localizedDescription
        
        // Immediately clean up the state rather than waiting
        if let lastGroup = currentThread.last {
            // Stop all messages in the group from replying
            for message in lastGroup.allMessages {
                message.isReplying = false
            }
        }
        
        // Call stopStreaming directly on the main thread
        self.stopStreaming()
    }
    
    @MainActor
    func generateTitle(forced: Bool = false) async {
        guard status != .quick else { return }
        guard forced || adjustedContext.count <= 2 else { return }

        let formattedPrompt = TitleFormatter.formatMessagesForTitleGeneration(messages: adjustedContext)
        
        do {
            let quickPanelModel = ChatConfigDefaults().quickPanelDefaultModel
            
            let userMessage = ChatRequestMessage(
                role: .user,
                content: [MessageContent(text: formattedPrompt)]
            )
            
            let client = OpenAIClient(
                apiKey: quickPanelModel.apiKey,
                baseURL: quickPanelModel.baseURL
            )
            
            let newTitle = try await client.sendSingleMessage(
                messages: [userMessage],
                model: quickPanelModel.modelString
            )
            
            title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            AppLogger.error("Error generating title: \(error)")
        }
    }

    func resetContext(at message: MessageGroup) {
        if contextResetPoint == message {
            contextResetPoint = nil
        } else {
            contextResetPoint = message
        }
        
        if let lastMessage = currentThread.last, lastMessage == message {
            Scroller.scrollToBottom()
        }
    }

    private func unsetContextResetPointIfNeeded(for messageGroup: MessageGroup) {
        guard let resetPoint = contextResetPoint,
              let resetIndex = currentThread.firstIndex(of: resetPoint),
              let messageIndex = currentThread.firstIndex(of: messageGroup),
              messageIndex <= resetIndex else {
            return
        }
        contextResetPoint = nil
    }
    
    @MainActor
    func deleteLastMessage() {
        guard let lastGroup = currentThread.last, !lastGroup.isReplying else { return }
        errorMessage = nil
        
        if lastGroup == contextResetPoint {
            contextResetPoint = nil
        }
        
        if currentThread.count == 1 {
            rootMessage = nil
            withAnimation { isEmpty = true }
        } else {
            let secondToLastGroup = currentThread[currentThread.count - 2]
            secondToLastGroup.activeMessage.next = nil
        }
        
        Scroller.scrollToBottom()
    }
    
    @MainActor
    func errorDeleteLast() {
        guard let last = self.currentThread.last else { return }
        
        // Stop all messages from replying and reset pending count
        for message in last.allMessages {
            message.isReplying = false
        }
        
        // Check if we should delete the entire group or just clean up empty messages
        let emptyMessages = last.allMessages.filter { $0.content.isEmpty && $0.dataFiles.isEmpty && $0.tools == nil }
        
        if emptyMessages.count == last.allMessages.count {
            // All messages are empty, delete the entire group
            if last.allMessages.count == 1 {
                self.deleteLastMessage()
            } else {
                // Remove empty messages and keep the last one
                while last.allMessages.count > 1 && last.activeMessage.content.isEmpty {
                    last.deleteAndSetPreviousActive()
                }
            }
        } else {
            // Remove only empty messages, keep non-empty ones
            while last.allMessages.count > 1 && last.activeMessage.content.isEmpty {
                last.deleteAndSetPreviousActive()
            }
        }
        
        // Check if thread became empty after cleanup
        if rootMessage == nil || currentThread.isEmpty {
            withAnimation { isEmpty = true }
        }
    }
    
    @MainActor
    func deleteAllMessages() {
        rootMessage = nil
        contextResetPoint = nil
        errorMessage = nil
        stopStreaming()
        withAnimation { isEmpty = true }
    }
    
    func copy(from message: Message? = nil) async -> Chat {
        let newChat = Chat()
        newChat.config = await self.config.copy()
        
        var threadToCopy: [MessageGroup] = []
        
        if let message = message {
            // Find the MessageGroup containing the specified message
            if let groupIndex = currentThread.firstIndex(where: { $0.allMessages.contains(message) }) {
                threadToCopy = Array(currentThread.prefix(through: groupIndex))
            }
        } else {
            threadToCopy = currentThread
        }
        
        // Copy the thread
        var previousGroup: MessageGroup?
        for group in threadToCopy {
            let copiedGroup = group.copy()
            
            if let previousGroup = previousGroup {
                previousGroup.activeMessage.next = copiedGroup
            } else {
                newChat.rootMessage = copiedGroup
            }
            
            previousGroup = copiedGroup
        }
        
        return newChat
    }
    
    @MainActor
    func cleanupMessagesAndGroups() {
        rootMessage = nil
        withAnimation { isEmpty = true }
    }
}
