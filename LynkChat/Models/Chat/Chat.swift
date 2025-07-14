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
    var totalTokens: Int = 0
    
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
    
    @Relationship(deleteRule: .cascade)
    var config: ChatConfig = ChatConfig()
    
    @Transient
    var streamingTask: Task<Void, Error>?
    @Transient
    var isReplying: Bool = false

    @Transient
    var inputManager = InputManager()
    
    init() { }
    
    func processRequest(message: Message) async {
        // Cancel any existing task first and wait for it to complete
        streamingTask?.cancel()
        if let task = streamingTask {
            try? await task.value // Wait for the task to finish after cancellation
        }
        
        errorMessage = nil
        date = Date()
        streamingTask = Task {
            let streamer = StreamHandler(chat: self, assistant: message)
            
            // Request background task before starting network operations
            #if !os(macOS)
            let backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.streamingTask?.cancel()
            }
            
            defer {
                // Ensure we end the background task when done
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
            }
            #endif
            
            do {
                try await streamer.handleRequest()
                
                // Generate title after streaming is complete
                if AppConfig.shared.autogenTitle {
                    await generateTitle()
                }
            } catch {
                handleError(error)
            }
            
            streamingTask?.cancel()
            streamingTask = nil
        }
    }

    func editMessage(_ message: Message) async {
        guard let userGroup = currentThread.first(where: { $0.activeMessage == message }) else { return }
        
        unsetContextResetPointIfNeeded(for: userGroup)
        
        let newUserMessage = Message.user(content: inputManager.prompt, dataFiles: inputManager.dataFiles)
        userGroup.addMessage(newUserMessage)
        
        let newAssistantMessage = Message.assistant(model: config.model)
        let newAssistantGroup = MessageGroup(message: newAssistantMessage)
        
        newUserMessage.next = newAssistantGroup
         
        await processRequest(message: newAssistantMessage)
    }
    

    func sendInput(prompt: String? = nil) async {
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
             
            await processRequest(message: assistantMessage)
        }
        
        // Reset inputManager after everything is done
        inputManager.reset()
    }

    func regenerate(message: MessageGroup) async {
        guard let index = currentThread.firstIndex(where: { $0 == message }) else { return }
       
        unsetContextResetPointIfNeeded(for: message)
       
        if message.role == .assistant {
            let newAssistantMessage = Message.assistant(model: config.model)
            message.addMessage(newAssistantMessage)
            message.activeMessage.next = nil
           
            await processRequest(message: newAssistantMessage)
        } else if message.role == .user {
            if index + 1 < currentThread.count {
                let assistantGroup = currentThread[index + 1]
                let newAssistantMessage = Message.assistant(model: config.model)
                assistantGroup.addMessage(newAssistantMessage)
                assistantGroup.activeMessage.next = nil
               
                await processRequest(message: newAssistantMessage)
            } else {
                let assistantMessage = Message.assistant(model: config.model)
                let assistantGroup = MessageGroup(message: assistantMessage)
                message.activeMessage.next = assistantGroup
                
                await processRequest(message: assistantMessage)
            }
        }
    }
    
    func stopStreaming() {
        guard let task = streamingTask else { return }
        task.cancel()
        streamingTask = nil
        isReplying = false // Set isReplying to false when stopped manually
        
        // Ensure the message is in a clean state before allowing new queries
        if let lastMessage = currentThread.last?.activeMessage {
            lastMessage.isReplying = false
            lastMessage.tools = nil
        }
        
        errorDeleteLast()
        withAnimation(.easeInOut(duration: 0.5)) {
            AppConfig.shared.expandColor = false
        }
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription.isEmpty ? "An unknown error occurred" : error.localizedDescription
        isReplying = false // Set isReplying to false on error
        
        // Immediately clean up the state rather than waiting
        if let lastMessage = currentThread.last?.activeMessage {
            lastMessage.isReplying = false
            lastMessage.tools = nil
        }
        
        // Call stopStreaming directly on the main thread
        self.stopStreaming()
    }
    
    func generateTitle(forced: Bool = false) async {
        guard status != .quick else { return }
        guard forced || adjustedContext.count <= 2 else { return }
        
        if let newTitle = await TitleGenerator.generateTitle(messages: adjustedContext) {
            title = newTitle
        }
    }

    func resetContext(at message: MessageGroup) {
        if contextResetPoint == message {
            contextResetPoint = nil
        } else {
            contextResetPoint = message
//            totalTokens = 0 // disabling since token count will help estimate usage
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
    
    func deleteLastMessage() {
        guard let lastGroup = currentThread.last, !lastGroup.isReplying else { return }
        errorMessage = nil
        
        if lastGroup == contextResetPoint {
            contextResetPoint = nil
        }
        
        if currentThread.count == 1 {
            rootMessage = nil
        } else {
            let secondToLastGroup = currentThread[currentThread.count - 2]
            secondToLastGroup.activeMessage.next = nil
        }
        
        Scroller.scrollToBottom()
    }
    
    func errorDeleteLast() {
        guard let last = self.currentThread.last else { return }
        last.activeMessage.isReplying = false
        last.activeMessage.tools = nil
        if last.activeMessage.content.isEmpty {
            if last.allMessages.count == 1 {
                self.deleteLastMessage()
            } else {
                last.deleteAndSetPreviousActive()
            }
        }
    }
    
    func deleteAllMessages() {
        rootMessage = nil
        contextResetPoint = nil
        errorMessage = nil
        totalTokens = 0
        stopStreaming()
    }
    
    func copy(from message: Message? = nil) async -> Chat {
        let newChat = Chat()
        newChat.config.model = self.config.model
        newChat.totalTokens = self.totalTokens
        
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
    
    func cleanupMessagesAndGroups() {
        rootMessage = nil
    }
}

enum ChatState: Codable {
    case notStarted
    case waiting
    case started
}
