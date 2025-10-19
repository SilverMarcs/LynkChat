//
//  MessageTypes.swift
//  SwiftAI
//
//  Created on 05/10/2025.
//

import Foundation

// MARK: - Message Types

enum MessageRole: String, Codable {
    case system
    case user
    case assistant
    case tool
}

enum MessageContentType: String, Codable {
     case text
     case imageUrl = "image_url"
     case file
}

enum PDFEngine: String, Codable {
     case native
     case pdfText = "pdf-text"
     case mistralOCR = "mistral-ocr"
}

struct FileAnnotation: Codable {
     let index: Int
     let type: String
     let text: String?
}

struct PDFFile: Codable {
     let filename: String
     let file_data: String
}

struct PDFFileContent: Codable {
     var type: String = "file"
     var file: PDFFile
}

struct MessageContent: Codable {
     var type: MessageContentType
     var text: String?
     var image_url: ImageURL?
     var file: PDFFile?
     
     struct ImageURL: Codable {
         let url: String
         let detail: String?
     }
     
     init(text: String) {
         self.type = .text
         self.text = text
         self.image_url = nil
         self.file = nil
     }
     
     init(image: ImageURL) {
         self.type = .imageUrl
         self.text = nil
         self.image_url = image
         self.file = nil
     }
     
     init(file: PDFFile) {
         self.type = .file
         self.text = nil
         self.image_url = nil
         self.file = file
     }
}

struct ChatRequestMessage: Codable {
      let role: MessageRole
      let content: [MessageContent]
      let tool_calls: [ToolCallInfo]?
      let tool_call_id: String?
      let reasoning_details: [ReasoningDetail]?
      var annotations: [FileAnnotation]?
      
      struct ToolCallInfo: Codable {
          let id: String
          let type: String
          let function: FunctionInfo
          
          struct FunctionInfo: Codable {
              let name: String
              let arguments: String
          }
      }
      
      init(role: MessageRole, content: [MessageContent], toolCalls: [ToolCallInfo]? = nil, toolCallId: String? = nil, reasoningDetails: [ReasoningDetail]? = nil, annotations: [FileAnnotation]? = nil) {
          self.role = role
          self.content = content
          self.tool_calls = toolCalls
          self.tool_call_id = toolCallId
          self.reasoning_details = reasoningDetails
          self.annotations = annotations
      }
}
