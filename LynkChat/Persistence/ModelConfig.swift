//
//  ModelConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI

class ModelConfig: ObservableObject {
    static let shared = ModelConfig()
    private init() {}
    
    @AppStorage("defaultModel") var defaultModel: ChatModel = .claude3_5haiku
    @AppStorage("quickModel") var quickModel: ChatModel = .claude3_5haiku
    
    @AppStorage("enable_claude3_5sonnet") var enable_claude3_5sonnet: Bool = true
    @AppStorage("enable_claude3_5haiku") var enable_claude3_5haiku: Bool = true
    @AppStorage("enable_gpt4o") var enable_gpt4o: Bool = true
    @AppStorage("enable_gpt4omini") var enable_gpt4omini: Bool = true
    @AppStorage("enable_gemini2Flash") var enable_gemini2Flash: Bool = true
    @AppStorage("enable_deepseek") var enable_deepseek: Bool = true
    @AppStorage("enable_llama_3_70") var enable_llama_3_70: Bool = true

    func binding(for model: ChatModel) -> Binding<Bool> {
       switch model {
       case .claude3_5sonnet:
           Binding(
               get: { self.enable_claude3_5sonnet },
               set: { self.enable_claude3_5sonnet = $0 }
           )
       case .claude3_5haiku:
           Binding(
               get: { self.enable_claude3_5haiku },
               set: { self.enable_claude3_5haiku = $0 }
           )
       case .gpt4o:
           Binding(
               get: { self.enable_gpt4o },
               set: { self.enable_gpt4o = $0 }
           )
       case .gpt4omini:
           Binding(
               get: { self.enable_gpt4omini },
               set: { self.enable_gpt4omini = $0 }
           )
       case .gemini2Flash:
           Binding(
               get: { self.enable_gemini2Flash },
               set: { self.enable_gemini2Flash = $0 }
           )
       case .deepseek:
           Binding(
               get: { self.enable_deepseek },
               set: { self.enable_deepseek = $0 }
           )
       case .llama3_70:
           Binding(
               get: { self.enable_llama_3_70 },
               set: { self.enable_llama_3_70 = $0 }
           )
       }
    }

    func isEnabled(_ model: ChatModel) -> Bool {
       switch model {
       case .claude3_5sonnet: return enable_claude3_5sonnet
       case .claude3_5haiku: return enable_claude3_5haiku
       case .gpt4o: return enable_gpt4o
       case .gpt4omini: return enable_gpt4omini
       case .gemini2Flash: return enable_gemini2Flash
       case .deepseek: return enable_deepseek
       case .llama3_70: return enable_llama_3_70
       }
    }

    var enabledModels: [ChatModel] {
       ChatModel.allCases.filter { isEnabled($0) }
    }
}
