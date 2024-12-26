//
//  AIModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 05/11/2024.
//

import Foundation
import SwiftData

@Model
// TODO: try making struct
class AIModel: Hashable, Identifiable {
    var id: UUID = UUID()
    var code: String
    var name: String
    var isEnabled: Bool
    var testResult: Bool?
    
    init(code: String, name: String, isEnabled: Bool = true) {
        self.code = code
        self.name = name
        self.isEnabled = isEnabled
    }
}

extension AIModel {
    static func getOpenaiModels() -> [AIModel] {
        return [
            .init(code: "gpt-4o-mini", name: "GPT-4om"),
            .init(code: "gpt-4o", name: "GPT-4o"),
            .init(code: "chatgpt-4o-latest", name: "ChatGPT-4o-Latest"),
            .init(code: "o1-mini", name: "o1-mini"),
            .init(code: "o1", name: "o1"),
            .init(code: "o1-preview", name: "o1-preview"),
        ]
    }
    
    static func getAnthropicModels() -> [AIModel] {
        return [
            .init(code: "claude-3-5-haiku-latest", name: "Claude-3.5H"),
            .init(code: "claude-3-5-sonnet-latest", name: "Claude-3.5S"),
        ]
    }
    
    static func getGoogleModels() -> [AIModel] {
        return [
            .init(code: "gemini-1.5-flash-latest", name: "Gemini-1.5F"),
            .init(code: "gemini-1.5-flash-8b-latest", name: "Gemini-1.5F-8B"),
            .init(code: "gemini-1.5-pro-latest", name: "Gemini-1.5P"),
            .init(code: "gemini-2.0-flash-exp", name: "Gemini-2F"),
        ]
    }
    
    static func getXaiModels() -> [AIModel] {
        return [
            .init(code: "grok-2-1212", name: "Grok-2"),
            .init(code: "grok-2-vision-121", name: "Grok-2V"),
        ]
    }
    
    static func getOpenrouterModels() -> [AIModel] {
        return [
            .init(code: "openai/gpt-4o-mini", name: "GPT-4om"),
            .init(code: "openai/gpt-4o", name: "GPT-4o"),
            .init(code: "anthropic/claude-3.5-sonnet", name: "Claude-3.5S"),
            .init(code: "anthropic/claude-3-5-haiku", name: "Claude-3.5H"),
            .init(code: "meta-llama/llama-3.1-8b-instruct", name: "Llama-3.1-8B"),
        ]
    }
    
    static func getGroqModels() -> [AIModel] {
        return [
            .init(code: "gemma2-9b-it", name: "Gemma-2-9B"),
            .init(code: "gemma-7b-it", name: "Gemma-7B"),
            .init(code: "llama3-groq-70b-8192-tool-use-preview", name: "LLaMA-3-Groq-70B"),
            .init(code: "llama3-groq-8b-8192-tool-use-preview", name: "LLaMA-3-Groq-8B"),
            .init(code: "llama-3.1-70b-versatile", name: "LLaMA-3.1-70B-Versatile"),
            .init(code: "llama-3.1-8b-instant", name: "LLaMA-3.1-8B-Instant"),
            .init(code: "llama-3.2-1b-preview", name: "LLaMA-3.2-1B"),
            .init(code: "llama-3.2-3b-preview", name: "LLaMA-3.2-3B"),
            .init(code: "llama-3.2-11b-vision-preview", name: "LLaMA-3.2-11B-Vision"),
            .init(code: "llama-3.2-90b-vision-preview", name: "LLaMA-3.2-90B-Vision"),
            .init(code: "llama-guard-3-8b", name: "LLaMA-Guard-3-8B"),
            .init(code: "llama3-70b-8192", name: "LLaMA-3-70B"),
            .init(code: "llama3-8b-8192", name: "LLaMA-3-8B"),
            .init(code: "mixtral-8x7b-32768", name: "Mixtral-8x7B"),
        ]
    }
    
    static func getMistralModels() -> [AIModel] {
        return [
            .init(code: "ministral-3b-latest", name: "Ministral-3B"),
            .init(code: "ministral-8b-latest", name: "Ministral-8B"),
            .init(code: "open-mistral-nemo", name: "Open-Mistral-Nemo"),
            .init(code: "mistral-small-latest", name: "Mistral-Small"),
            .init(code: "mistral-medium-latest", name: "Mistral-Medium"),
            .init(code: "mistral-large-latest", name: "Mistral-Large"),
            .init(code: "codestral-latest", name: "Codestral"),
            .init(code: "pixtral-12b-2409", name: "Pixtral-12B-2409"),
        ]
    }
    
    static func getPerplexityModels() -> [AIModel] {
        return [
            .init(code: "llama-3.1-sonar-small-128k-online", name: "Llama-3.1-sonar-small-online"),
            .init(code: "llama-3.1-sonar-large-128k-online", name: "Llama-3.1-sonar-large-online"),
            .init(code: "llama-3.1-sonar-huge-128k-online", name: "Llama-3.1-sonar-huge-online"),
            .init(code: "llama-3.1-sonar-small-128k-chat", name: "Llama-3.1-sonar-small-chat"),
            .init(code: "llama-3.1-sonar-large-128k-chat", name: "Llama-3.1-sonar-large-chat"),
            .init(code: "llama-3.1-sonar-small-128k-chat", name: "Llama-3.1-sonar-small-chat"),
            .init(code: "llama-3.1-sonar-large-128k-chat", name: "Llama-3.1-sonar-large-chat"),
            .init(code: "llama-3.1-8b-instruct", name: "Llama-3.1-8B"),
            .init(code: "llama-3.1-70b-instruct", name: "Llama-3.1-70B"),
        ]
    }
    
    static func getTogetherModels() -> [AIModel] {
        return [
            .init(code: "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo", name: "Meta-Llama-3.1-8B-Instruct-Turbo"),
            .init(code: "meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo", name: "Meta-Llama-3.1-70B-Instruct-Turbo"),
            .init(code: "meta-llama/Meta-Llama-3.1-405B-Instruct-Turbo", name: "Meta-Llama-3.1-405B-Instruct-Turbo"),
            .init(code: "meta-llama/Llama-3.2-3B-Instruct-Turbo", name: "Llama-3.2-3B-Instruct-Turbo"),
            .init(code: "meta-llama/Llama-3.2-11B-Vision-Instruct-Turbo", name: "Llama-3.2-11B-Vision-Instruct-Turbo"),
            .init(code: "meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo", name: "Llama-3.2-90B-Vision-Instruct-Turbo"),
            .init(code: "microsoft/WizardLM-2-8x22B", name: "WizardLM-2-8x22B"),
            .init(code: "google/gemma-2-27b-it", name: "Gemma-2-27B"),
            .init(code: "google/gemma-2-9b-it", name: "Gemma-2-9B"),
            .init(code: "google/gemma-2b-it", name: "Gemma-2B"),
            .init(code: "deepseek-ai/deepseek-lIm-67b-chat", name: "Deepseek-LIM-67B-Chat"),
            .init(code: "Gryphe/MythoMax-L2-13b", name: "MythoMax-L2-13B"),
            .init(code: "mistralai/Mistral-7B-Instruct-v0.3", name: "Mistral-7B-Instruct-V0.3"),
            .init(code: "mistralai/Mixtral-8x7B-Instruct-v0.3", name: "Mixtral-8x7B-Instruct-V0.3"),
            .init(code: "mistralai/Mixtral-8x22B-Instruct-V0.1", name: "Mixtral-8x22B-Instruct-V0.1"),
            .init(code: "NousResearch/Nous-Hermes-2-Mixtral-8x7B-DPO", name: "Nous-Hermes-2-Mixtral-8x7B-DPO"),
            .init(code: "Qwen/Qwen2.5-7B-Instruct-Turbo", name: "Qwen2.5-7B-Instruct-Turbo"),
            .init(code: "Qwen/Qwen2.5-72B-Instruct-Turbo", name: "Qwen2.5-72B-Instruct-Turbo"),
            .init(code: "Qwen/Qwen2.5-Coder-32B-Instruct", name: "Qwen2.5-Coder-32B-Instruct"),
        ]
    }
    
    static func getLocalModels() -> [AIModel] {
        return [
            .init(code: "dummy-chat-model", name: "Dummy-Chat"),
        ]
    }
    
    static func getBedrockModels() -> [AIModel] {
        return [
            .init(code: "us.anthropic.claude-3-5-haiku-20241022-v1:0", name: "Claude-3.5H"),
            .init(code: "us.anthropic.claude-3-5-sonnet-20241022-v2:0", name: "Claude-3.5S"),
        ]
    }
}
