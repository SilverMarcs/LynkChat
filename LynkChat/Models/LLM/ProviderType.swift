//
//  ProviderType.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/07/2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum ProviderType: String, Codable, CaseIterable, Identifiable {
    case lynkchat
    case openai
    case openrouter
    case groq
    case xai
    case mistral
    case perplexity
    case togetherai
    case github
    case anthropic
    case google
    case bedrock
    case deepseek
    case ollama
    case lmstudio
    case customOpenai
    case customAnthropic
    case customGoogle

    var id: ProviderType { self }

    var scheme: HTTPScheme {
        switch self {
        case .ollama, .lmstudio: .http
        default: .https
        }
    }
    
    var name: String {
        switch self {
        case .lynkchat: "LynkChat"
        case .openai: "OpenAI"
        case .openrouter: "OpenRouter"
        case .anthropic: "Anthropic"
        case .bedrock: "Bedrock"
        case .deepseek: "DeepSeek"
        case .groq: "Groq"
        case .xai: "xAI"
        case .mistral: "MistralAI"
        case .perplexity: "PerplexityAI"
        case .togetherai: "TogetherAI"
        case .github: "Github"
        case .google: "Google"
        case .ollama: "Ollama"
        case .lmstudio: "LMStudio"
        case .customOpenai: "Custom OpenAI"
        case .customAnthropic: "Custom Anthropic"
        case .customGoogle: "Custom Google"
        }
    }
    
    var imageName: String {
        switch self {
        case .lynkchat: "storm.SFSymbol"
        case .openai, .customOpenai: "openai.SFSymbol"
        case .anthropic, .customAnthropic: "anthropic.SFSymbol"
        case .google, .customGoogle: "google.SFSymbol"
        case .bedrock: "bedrock.SFSymbol"
        case .deepseek: "deepseek.SFSymbol"
        case .openrouter: "openrouter.SFSymbol"
        case .mistral: "mistral.SFSymbol"
        case .perplexity: "perplexity.SFSymbol"
        case .xai: "xai.SFSymbol"
        case .groq: "groq.SFSymbol"
        case .github: "github.SFSymbol"
        case .togetherai: "togetherai.SFSymbol"
        case .ollama: "ollama.SFSymbol"
        case .lmstudio: "brain.SFSymbol"
        }
    }
    
    var defaultColor: String {
        switch self {
        case .lynkchat: "#6765D5"
        case .openai: "#00947A"
        case .anthropic: "#E6784B"
        case .google: "#E64335"
        case .deepseek: "#4F65E9"
        case .bedrock: "#f46d25"
        case .openrouter: "#7a8799"
        case .mistral: "#EB5A29"
        case .perplexity: "#2F7999"
        case .xai: "#111111"
        case .groq: "#F55036"
        case .github: "#181717"
        case .togetherai : "#106CF9"
        case .ollama: "#EFEFEF"
        default: Color.randomColors.randomElement() ?? "#00947A"
        }
    }
    
    // TODO: for subscription models, show sub button wth credist remaining instead of base url
    var defaultHost: String {
        switch self {
        case .lynkchat: "lynkchat.com"
        case .openai, .customOpenai: "api.openai.com/v1"
        case .anthropic, .customAnthropic: "api.anthropic.com"
        case .google, .customGoogle: "generativelanguage.googleapis.com"
        case .bedrock: "api.bedrock.com"
        case .deepseek: "api.deepseek.com/v1"
        case .github: "models.inference.ai.azure.com"
        case .perplexity: "api.perplexity.ai"
        case .groq: "api.groq.com/openai/v1"
        case .xai: "api.x.ai/v1"
        case .openrouter: "openrouter.ai/api/v1"
        case .mistral: "api.mistral.ai/v1"
        case .togetherai: "api.together.xyz/v1"
        case .lmstudio: "localhost:1234/v1"
        case .ollama: "localhost:11434//c1"
        }
    }
    
//    func getService() -> any AIService.Type {
////        switch self {
////            // TODO: do v soon
////        case .lynkchat:
////            APIService.self
////        case .customOpenai, .lmstudio, .ollama:
////            OpenAIService.self
////        case .customGoogle:
////            OpenAIService.self
//////        case .customAnthropic:
//////            CustomAnthropicService.self
////        default:
////            OpenAIService.self
////        }
//        APIService.self
//    }
    
    static var usesCustomOpenAI: [ProviderType] = [.customOpenai, .lmstudio, .ollama, .customGoogle, .customAnthropic]
    static var usesCustomGoogleOrAnthropic: [ProviderType] = [.customGoogle, .customAnthropic]
    // add both lists
    static var customTypes: [ProviderType] = usesCustomOpenAI + usesCustomGoogleOrAnthropic
    

    func getDefaultModels() -> [AIModel] {
        switch self {
        case .lynkchat: AIModel.getLynkChatModels()
        case .openai, .customOpenai: AIModel.getOpenaiModels()
        case .anthropic, .customAnthropic: AIModel.getAnthropicModels()
        case .google, .customGoogle: AIModel.getGoogleModels()
        case .bedrock: AIModel.getBedrockModels() // TODO: change
        case .deepseek: AIModel.getDeepseekModels()
        case .xai: AIModel.getXaiModels()
        case .openrouter: AIModel.getOpenrouterModels()
        case .github: AIModel.getOpenaiModels()
        case .groq: AIModel.getGroqModels()
        case .mistral: AIModel.getMistralModels()
        case .perplexity: AIModel.getPerplexityModels()
        case .togetherai: AIModel.getTogetherModels()
        case .lmstudio: AIModel.getLocalModels()
        case .ollama: AIModel.getLocalModels()
        }
    }
    
//    var extraInfo: String {
//        switch self {
//        case .openai: "Get OpenAI API key [here](https://platform.openai.com/settings/organization/api-keys)"
//        case .anthropic: "Get Anthropic API key [here](https://console.anthropic.com/settings/keys)"
//        case .google: "Get Google API key [here](https://aistudio.google.com/app/apikey)"
//        case .bedrock: "Only us-east-1 is supported. Put Secrents in this format: ACCESS_KEY||SECRET_ACCESS_SECRET"
//        case .ollama: "Download and setup Ollama from [here](https://ollama.com/download/mac)"
//        case .lmstudio: "Download and setup LMStudio from [here](https://lmstudio.ai/download)"
//        case .xai: "Get xAI API key [here](https://console.x.ai) and click on key icon"
//        case .groq: "Get Groq API key [here](https://console.groq.com/keys)"
//        case .openrouter: "Get OpenRouter API key [here](https://openrouter.ai/settings/keys)"
//        case .mistral: "Get Mistral API key [here](https://console.mistral.ai/api-keys)"
//        case .perplexity: "Get Perplexity API key [here](https://www.perplexity.ai/settings/api)"
//        case .togetherai: "Get TogetherAI API key [here](https://api.together.ai/settings/api-keys)"
//        case .github: "Get Github Personal Access Token key [here](https://github.com/settings/tokens)"
//        case .custom: "Include http:// or https:// in the front and /v1 at the end if applicable"
//        }
//    }
    
    var extraInfo: String {
        switch self {
        case .customOpenai, .lmstudio, .ollama: "Include http:// or https:// in the front and /v1 at the end if applicable"
        case .customGoogle: "Get Google API key [here](https://aistudio.google.com/app/apikey)"
        case .customAnthropic: "Get Anthropic API key [here](https://console.anthropic.com/settings/keys"
        default: "This API Service is bundled with a paid subcription. Create Custom providers for using own API Keys"
        }
    }
    
    static let primaryProviders: [ProviderType] = [
        .openai, .google, .anthropic
    ]
    
    static let otherProviders: [ProviderType] = [
        .openrouter, .bedrock, .deepseek, .github, .groq,
        .xai, .mistral, .perplexity, .togetherai
    ]
    
    static let localProviders: [ProviderType] = [
        .lmstudio, .ollama
    ]
}

extension ProviderType {
    enum Group: String {
        case primary = "Primary Providers"
        case other = "Other Providers"
        case local = "Local Providers"
        case custom = "Custom"
        
        var providers: [ProviderType] {
            switch self {
            case .primary: return ProviderType.primaryProviders
            case .other: return ProviderType.otherProviders
            case .local: return ProviderType.localProviders
            case .custom: return [.customOpenai, .customGoogle, .customAnthropic]
            }
        }
    }
    
    static let groups: [Group] = [.primary, .other, .local, .custom]
}
