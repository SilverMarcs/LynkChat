//
//  Message.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/06/2024.
//

import Foundation
import SwiftData

@Model
final class Message: Equatable, Identifiable, Hashable {
     var id: UUID = UUID()
     var date: Date = Date()
     
     var model: ChatModel
     var role: Role
     var content: String
     var reasoningDetails: [ReasoningDetail]?

     @Relationship(deleteRule: .cascade)
     var dataFiles: [TypedData]
     
     @Attribute(.ephemeral)
     var isReplying: Bool = false
     
     var height: CGFloat
     
     @Relationship(deleteRule: .cascade)
     var next: MessageGroup?
     
     var tools: [ChatTool]?
     
     var inputTokens: Int = 0
     var outputTokens: Int = 0
     var reasoningTokens: Int = 0
     
     var fileAnnotations: [FileAnnotation]?
    
      private init(role: Role,
                   content: String = "",
                   reasoningDetails: [ReasoningDetail]? = nil,
                   model: ChatModel,
                   dataFiles: [TypedData],
                   tools: [ChatTool]?,
                   isReplying: Bool = false,
                   height: CGFloat,
                   inputTokens: Int = 0,
                   outputTokens: Int = 0,
                   reasoningTokens: Int = 0,
                   fileAnnotations: [FileAnnotation]? = nil) {
          self.role = role
          self.content = content
          self.reasoningDetails = reasoningDetails
          self.model = model
          self.dataFiles = dataFiles
          self.tools = tools
          self.isReplying = isReplying
          self.height = height
          self.inputTokens = inputTokens
          self.outputTokens = outputTokens
          self.reasoningTokens = reasoningTokens
          self.fileAnnotations = fileAnnotations
      }

      func copy() -> Message {
          return Message(
              role: role,
              content: content,
              reasoningDetails: reasoningDetails,
              model: model,
              dataFiles: dataFiles,
              tools: tools,
              isReplying: isReplying,
              height: height,
              inputTokens: inputTokens,
              outputTokens: outputTokens,
              reasoningTokens: reasoningTokens,
              fileAnnotations: fileAnnotations
          )
      }
    
    static func user(content: String, dataFiles: [TypedData] = []) -> Message {
        return Message(
            role: .user,
            content: content,
            model: ChatModel(modelString: "", name: "", baseURL: "", apiKey: ""),
            dataFiles: dataFiles,
            tools: nil,
            isReplying: false,
            height: 20
        )
    }
    
    static func assistant(model: ChatModel, content: String = "") -> Message {
        Message(
            role: .assistant,
            content: content,
            model: model,
            dataFiles: [],
            tools: [],
            isReplying: true,
            height: 0
        )
    }

    enum Role: String, Codable {
        case user
        case assistant
    }
}

extension Message {
    func toChatRequestMessage() -> [ChatRequestMessage] {
        var messageContents = [MessageContent]()
        
        messageContents.append(MessageContent(text: content))
        
        for dataFile in dataFiles {
            if dataFile.fileType.conforms(to: .text) {
                messageContents.append(MessageContent(text: dataFile.formattedTextContent))
            } else if dataFile.fileType.conforms(to: .image) {
                let dataURL = OpenAIClient.imageDataURL(from: dataFile.data, mimeType: dataFile.mimeType)
                let imageURL = MessageContent.ImageURL(url: dataURL, detail: nil)
                messageContents.append(MessageContent(image: imageURL))
            } else if dataFile.fileType.conforms(to: .pdf) {
                let dataURL = OpenAIClient.pdfDataURL(from: dataFile.data)
                let pdfFile = PDFFile(filename: dataFile.fileName, file_data: dataURL)
                messageContents.append(MessageContent(file: pdfFile))
            }
        }
        
        var messages: [ChatRequestMessage] = []
        
        if role == .assistant, let tools = tools, !tools.isEmpty {
            let toolCalls = tools.map { tool in
                ChatRequestMessage.ToolCallInfo(
                    id: tool.toolCallId,
                    type: "function",
                    function: ChatRequestMessage.ToolCallInfo.FunctionInfo(
                        name: tool.toolName,
                        arguments: tool.args
                    )
                )
            }
            
            messages.append(ChatRequestMessage(
                role: .assistant,
                content: content.isEmpty ? [] : messageContents,
                toolCalls: toolCalls,
                reasoningDetails: reasoningDetails,
                annotations: fileAnnotations
            ))
            
            for tool in tools where tool.result != nil {
                messages.append(ChatRequestMessage(
                    role: .tool,
                    content: [MessageContent(text: String(tool.result!.prefix(20000)))],
                    toolCallId: tool.toolCallId
                ))
            }
        } else if role == .assistant {
            messages.append(ChatRequestMessage(
                role: .assistant,
                content: messageContents,
                reasoningDetails: reasoningDetails,
                annotations: fileAnnotations
            ))
        } else {
            messages.append(ChatRequestMessage(
                role: .user,
                content: messageContents,
                reasoningDetails: reasoningDetails,
                annotations: fileAnnotations
            ))
        }
        
        return messages
    }
}
