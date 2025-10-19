import Foundation

enum ModelTheme: String, Codable, Sendable, CaseIterable {
    case openai
    case gemini
    case claude
    case other
    
    var imageName: String {
        switch self {
        case .openai: "openai.symbols"
        case .gemini: "gemini.symbols"
        case .claude: "claude.symbols"
        case .other: "cohere.symbols"
        }
    }
    
    var color: String {
        switch self {
        case .openai: "#00947A"
        case .gemini: "#E64335"
        case .claude: "#D6683B"
        case .other: "#007BFF"
        }
    }
    
    var displayName: String {
        switch self {
        case .openai: "OpenAI"
        case .gemini: "Gemini"
        case .claude: "Claude"
        case .other: "Other"
        }
    }
}
