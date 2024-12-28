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
    var errorMessage: String = ""
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
    var isReplying: Bool {
        currentThread.last?.isReplying ?? false
    }

    @Transient
    var inputManager = InputManager()
    
    init() { }
    
    @MainActor
    func processRequest(message: Message) async {
        errorMessage = ""
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
                scrollDown()
                
                try await streamer.handleRequest()
            } catch {
                handleError(error)
            }
            
            streamingTask?.cancel()
            streamingTask = nil
        }
        
        if AppConfig.shared.autogenTitle {
            Task { await generateTitle() }
        }
    }

    @MainActor
    func editMessage(_ message: Message) async {
        guard let userGroup = currentThread.first(where: { $0.activeMessage == message }) else { return }
        
        unsetContextResetPointIfNeeded(for: userGroup)
        
        let newUserMessage = Message(role: .user, content: inputManager.prompt, model: message.model, dataFiles: inputManager.dataFiles)
        userGroup.addMessage(newUserMessage)
        
        let newAssistantMessage = Message(role: .assistant, model: config.model, isReplying: true)
        let newAssistantGroup = MessageGroup(message: newAssistantMessage)
        newAssistantGroup.chat = self
        
        newUserMessage.next = newAssistantGroup
         
        await processRequest(message: newAssistantMessage)
    }
    

    @MainActor
    func sendInput() async {
        guard !inputManager.prompt.isEmpty else { return }
        inputManager.prompt = inputManager.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        errorMessage = ""
        resetScroll()
        
        if let editingMessage = inputManager.editingMessage {
            await editMessage(editingMessage)
            inputManager.editingMessage = nil
        } else {
            let userMessage = Message(role: .user, content: inputManager.prompt, model: config.model, dataFiles: inputManager.dataFiles)
            let userGroup = MessageGroup(message: userMessage)
            userGroup.chat = self
            
            if rootMessage == nil {
                rootMessage = userGroup
            } else {
                let lastGroup = currentThread.last!
                lastGroup.activeMessage.next = userGroup
            }
            
            let assistantMessage = Message(role: .assistant, model: config.model, isReplying: true)
            let assistantGroup = MessageGroup(message: assistantMessage)
            assistantGroup.chat = self
            userGroup.activeMessage.next = assistantGroup
             
            await processRequest(message: assistantMessage)
        }
         
        inputManager.reset()
    }

    @MainActor
    func regenerate(message: MessageGroup) async {
        guard let index = currentThread.firstIndex(where: { $0 == message }) else { return }
        resetScroll()
       
        unsetContextResetPointIfNeeded(for: message)
       
        if message.role == .assistant {
            let newAssistantMessage = Message(role: .assistant, model: config.model)
            message.addMessage(newAssistantMessage)
            message.activeMessage.next = nil
           
            await processRequest(message: newAssistantMessage)
        } else if message.role == .user {
            if index + 1 < currentThread.count {
                let assistantGroup = currentThread[index + 1]
                let newAssistantMessage = Message(role: .assistant, model: config.model)
                assistantGroup.addMessage(newAssistantMessage)
                assistantGroup.activeMessage.next = nil
               
                await processRequest(message: newAssistantMessage)
            } else {
                let assistantMessage = Message(role: .assistant, model: config.model, isReplying: true)
                let assistantGroup = MessageGroup(message: assistantMessage)
                assistantGroup.chat = self
                message.activeMessage.next = assistantGroup
                
                await processRequest(message: assistantMessage)
            }
        }
    }
    
    func stopStreaming() {
        resetScroll()
        streamingTask?.cancel()
        streamingTask = nil
        errorDeleteLast()
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription.isEmpty ? "An unknown error occurred" : error.localizedDescription
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            self.stopStreaming()
        }
    }
    
    func generateTitle(forced: Bool = false) async {
        guard status != .quick else { return }
        guard forced || adjustedContext.count <= 2 else { return }
        
        if let newTitle = await TitleGenerator.generateTitle(messages: adjustedContext) {
            self.title = newTitle
        }
    }

    func resetContext(at message: MessageGroup) {
        if contextResetPoint == message {
            contextResetPoint = nil
        } else {
            contextResetPoint = message
            totalTokens = 0
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
        
        if lastGroup == contextResetPoint {
            contextResetPoint = nil
        }
        
        if currentThread.count == 1 {
            let temp = rootMessage
            rootMessage = nil
            temp?.chat = nil
        } else {
            let secondToLastGroup = currentThread[currentThread.count - 2]
            secondToLastGroup.activeMessage.next = nil
            lastGroup.chat = nil
        }
        
        Scroller.scrollToBottom()
    }
    
    func errorDeleteLast() {
        guard let last = self.currentThread.last else { return }
        last.isReplying = false
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
        stopStreaming()
        errorMessage = ""
        totalTokens = 0
    }
    
    func scrollDown() {
        guard !AppConfig.shared.hasUserScrolled else { return }
        Scroller.scrollToBottom()
    }
    
    func resetScroll() {
        DispatchQueue.main.async {
            AppConfig.shared.hasUserScrolled = false
        }
    }
    
    func copy(from message: Message? = nil) async -> Chat {
        let newChat = Chat()
        newChat.config.model = self.config.model
        
//        let leading = switch purpose {
//            case .chat: "Ψ"
//            case .quick: "↯"
//            case .title: "T"
//        }
        
//        newChat.title = "\(leading) \(self.title)"
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
            copiedGroup.chat = newChat
            
            if let previousGroup = previousGroup {
                previousGroup.activeMessage.next = copiedGroup
            } else {
                newChat.rootMessage = copiedGroup
            }
            
            previousGroup = copiedGroup
        }
        
        return newChat
    }
}
