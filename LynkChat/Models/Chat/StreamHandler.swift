//
//  StreamHandler.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct StreamHandler {
    let chat: Chat
    let assistant: Message
    let user: Message
    
    func handleRequest() async throws {
        let apiRequest = await createAPIRequest()
        try await processStream(from: apiRequest)
        
        finishResponse()
    }
    
    // MARK: - Stream Processing
    
    private func processStream(from request: APIRequest) async throws {
        // Local buffers for batching updates
        var contentBuffer = ""
        var reasoningBuffer = assistant.reasoning ?? ""
        
        // Timer for periodic updates
        let updateInterval: TimeInterval = 0.2
        var lastUpdateTime = Date()
        
        // Helper function to update UI
        func updateUI() {
            assistant.content = contentBuffer
            assistant.reasoning = reasoningBuffer.isEmpty ? nil : reasoningBuffer
        }
        
        for try await response in APIService.streamResponse(from: request) {
            try Task.checkCancellation()
            
            switch response {
            case .text(let textResponse):
                contentBuffer += textResponse.content
                
            case .reasoning(let reasoningResponse):
                reasoningBuffer += reasoningResponse.reasoning
                
            case .reasoningEnd(_):
                break
                
            case .toolCall(let toolCallResponse):
                updateTools(with: toolCallResponse)
                
            case .toolResult(let toolResultResponse):
                updateToolResult(for: toolResultResponse)
                
            case .file(let fileResponse):
                if let data = Data(base64Encoded: fileResponse.base64),
                   let utType = UTType(mimeType: fileResponse.mimeType) {
                    let fileExtension = utType.preferredFilenameExtension ?? "dat"
                    let fileName = "file_\(UUID().uuidString).\(fileExtension)"
                    let typedData = TypedData(
                        data: data,
                        fileType: utType,
                        fileName: fileName
                    )
                    assistant.dataFiles.append(typedData)
                }
                
            case .finish(let finishResponse):
                user.inputTokens += finishResponse.inputTokens
                assistant.outputTokens += finishResponse.outputTokens
                assistant.reasoningTokens += finishResponse.reasoningTokens
                
            case .error(let errorResponse):
                throw RuntimeError(errorResponse.content)
            }
            
            // Periodic UI updates
            let now = Date()
            if now.timeIntervalSince(lastUpdateTime) >= updateInterval {
                updateUI()
                lastUpdateTime = now
                #if !os(macOS)
                BackgroundStreamTask.tickProgress()
                #endif
            }
        }
        
        try Task.checkCancellation()
        
        // Final update to ensure all content is set
        updateUI()
    }
    
    // MARK: - Helper Methods
    
    private func createAPIRequest() async -> APIRequest {
        let adjustedContext = chat.adjustedContext.dropLast() // removing last assistant msg
        let apiMessages = adjustedContext.map { $0.toAPIMessage() }
        return createAPIRequest(with: apiMessages)
    }
    
    private func createAPIRequest(with messages: [APIMessage]) -> APIRequest {
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"

        return APIRequest(
            userId: "zabir",
            model: chat.config.model.id,
            messages: messages,
            temperature: chat.config.temperature.value,
            thinkingBudget: chat.config.thinkingBudget.rawValue,
            system: date + "\n" + chat.config.systemPrompt
        )
    }
    
    private func updateTools(with toolCallResponse: ToolCallResponse) {
        assistant.tools?.append(.init(
            toolCallId: toolCallResponse.toolCallId,
            toolName: toolCallResponse.toolName,
            args: toolCallResponse.args,
            result: nil
        ))
    }
    
    private func updateToolResult(for toolResultResponse: ToolResultResponse) {
        if let index = assistant.tools?.firstIndex(where: { $0.toolCallId == toolResultResponse.toolCallId }) {
            assistant.tools?[index].result = toolResultResponse.result
        }
    }
    
    private func finishResponse() {
        assistant.isReplying = false
        assistant.reasoning = assistant.reasoning?.trimmingCharacters(in: .whitespacesAndNewlines)
 
        // TODO: check this logic
        // Delete response if content is empty and no data files or tools were used
        if assistant.content.isEmpty && assistant.dataFiles.isEmpty && assistant.tools == nil {
            chat.errorDeleteLast()
        }
        
        withAnimation(.easeInOut(duration: 1)) { chat.expandColor = false }
    }
}
