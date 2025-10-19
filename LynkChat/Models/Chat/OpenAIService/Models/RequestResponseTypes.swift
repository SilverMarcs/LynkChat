//
//  RequestResponseTypes.swift
//  SwiftAI
//
//  Created on 05/10/2025.
//

import Foundation

// MARK: - Request/Response Types

struct ChatCompletionRequest: Codable {
     let model: String
     let messages: [ChatRequestMessage]
     let stream: Bool
     let temperature: Double?
     let max_tokens: Int?
     let tools: [Tool]?
     let reasoning: Reasoning?
     let plugins: [Plugin]?
     
     struct Tool: Codable {
         let type: String
         let function: Function
         
         struct Function: Codable {
             let name: String
             let description: String?
             let parameters: [String: AnyCodable]?
         }
     }
     
     struct Reasoning: Codable {
         let effort: ThinkingBudget
     }
     
     struct Plugin: Codable {
         let id: String
         let pdf: PDFConfig
         
         struct PDFConfig: Codable {
             let engine: PDFEngine
         }
     }
}

struct ChatStreamResponse: Codable {
     let id: String?
     let object: String?
     let created: Int?
     let model: String?
     let choices: [StreamChoice]
     let usage: Usage?
     
      struct StreamChoice: Codable {
          let index: Int
          let delta: Delta
          let finish_reason: String?
          var message: Message?
          
          struct Message: Codable {
              let annotations: [FileAnnotation]?
          }
          
          struct Delta: Codable {
              let role: String?
              let content: String?
              let reasoning: String?
              let reasoning_details: [ReasoningDetail]?
              let tool_calls: [ToolCall]?
              
              struct ToolCall: Codable {
                  let index: Int?
                  let id: String?
                  let type: String?
                  let function: FunctionCall?
                  
                  struct FunctionCall: Codable {
                      let name: String?
                      let arguments: String?
                  }
              }
          }
      }
    
    struct Usage: Codable {
        let prompt_tokens: Int?
        let completion_tokens: Int?
        let total_tokens: Int?
        let completion_tokens_details: CompletionTokensDetails?
        
        struct CompletionTokensDetails: Codable {
            let reasoning_tokens: Int?
        }
     }
}

struct ReasoningDetail: Codable, Equatable, Hashable {
     enum ReasoningType: String, Codable {
         case summary = "reasoning.summary"
         case text = "reasoning.text"
         case encrypted = "reasoning.encrypted"
     }
     
     let type: ReasoningType
     let id: String?
     let format: String?
     let index: Int?
     
     var summary: String?
     var text: String?
     let signature: String?
     var data: String?
     
     enum CodingKeys: String, CodingKey {
         case type, id, format, index, summary, text, signature, data
     }
}
