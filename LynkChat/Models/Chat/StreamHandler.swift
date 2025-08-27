//
//  StreamHandler.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation
import SwiftUI

struct StreamHandler {
    let chat: Chat
    let assistant: Message
    private static var chainedFollowUpIds = Set<UUID>() // track assistant messages already chained

    func handleRequest() async throws {
        chat.isReplying = true
        AppSettings.shared.expandColor = true
        Scroller.scrollToBottom()
        
        let apiRequest = await createAPIRequest()
        try await processStream(from: apiRequest)
        
        // Attempt chained follow-up once (web search or rag tool result -> second call)
        if let followUp = extractToolFollowUp(), !Self.chainedFollowUpIds.contains(assistant.id) {
            Self.chainedFollowUpIds.insert(assistant.id)
            assistant.isReplying = true
            chat.isReplying = true
            try await streamFollowUp(followUpPrompt: followUp)
        }
        
        finishResponse()
    }
    
    // MARK: - Stream Processing
    
    private func processStream(from request: APIRequest) async throws {
        var streamText = assistant.content // preserve existing content for follow-ups
        var reasoning = assistant.reasoning ?? ""
        
        for try await response in APIService.streamResponse(from: request) {
            switch response {
            case .text(let textResponse):
                streamText += textResponse.content
                assistant.content = streamText

            case .reasoning(let reasoningResponse):
                chat.isReasoning = true
                reasoning += reasoningResponse.reasoning
                assistant.reasoning = reasoning

            case .reasoningEnd(_):
                chat.isReasoning = false

            case .toolCall(let toolCallResponse):
                updateTools(with: toolCallResponse)

            case .toolResult(let toolResultResponse):
                updateToolResult(for: toolResultResponse)

            case .finish(let finishResponse):
                chat.totalTokens = finishResponse.totalTokens

            case .error(let errorResponse):
                throw RuntimeError(errorResponse.content)
            }
        }
    }
    
    private func streamFollowUp(followUpPrompt: String) async throws {
        let baseContext = chat.adjustedContext // full context including last assistant
        var apiMessages = baseContext.map { $0.toAPIMessage() }
        // Inject virtual assistant message with the follow-up prompt
        apiMessages.append(APIMessage(role: .assistant, content: [.text(followUpPrompt)]))
        
        let request = createAPIRequest(with: apiMessages)
        try await processStream(from: request)
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
            model: AppConfig.shared.sendDebugModel ? "debug" : chat.config.model.id,
            messages: messages,
            temperature: chat.config.temperature.value,
            thinkingBudget: chat.config.thinkingBudget.rawValue,
            system: date + "\n" + chat.config.systemPrompt + "\n" + String.toolExtras + chat.config.enabledTools.map { $0.toolPrompt }.joined(separator: "\n"),
            tools: chat.config.enabledTools.map { $0.rawValue }
        )
    }

    // Determine if a web search or rag tool result should be auto-sent as a follow-up.
    private func extractToolFollowUp() -> String? {
        return assistant.tools?
            .compactMap(\.result)
            .first(where: \.requiresFollowUp)?
            .textContent
    }
    
    private func updateTools(with toolCallResponse: ToolCallResponse) {
        assistant.tools?.append(.init(
            toolCallId: toolCallResponse.toolCallId,
            tool: toolCallResponse.tool,
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
        chat.isReplying = false
        withAnimation(.easeInOut(duration: 1)) { AppSettings.shared.expandColor = false }
    }
}
