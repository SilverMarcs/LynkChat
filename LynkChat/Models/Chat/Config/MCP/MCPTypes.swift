import Foundation

enum MCPToolContent: Codable {
    case text(String)
    case image(data: String, mimeType: String, metadata: [String: AnyCodable]?)
    case audio(data: String, mimeType: String)
    case resource(uri: String, mimeType: String?, text: String?)
    
    enum CodingKeys: String, CodingKey {
        case type, text, data, mimeType, metadata, uri
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            self = .text(try container.decode(String.self, forKey: .text))
        case "image":
            self = .image(
                data: try container.decode(String.self, forKey: .data),
                mimeType: try container.decode(String.self, forKey: .mimeType),
                metadata: try container.decodeIfPresent([String: AnyCodable].self, forKey: .metadata)
            )
        case "audio":
            self = .audio(
                data: try container.decode(String.self, forKey: .data),
                mimeType: try container.decode(String.self, forKey: .mimeType)
            )
        case "resource":
            self = .resource(
                uri: try container.decode(String.self, forKey: .uri),
                mimeType: try container.decodeIfPresent(String.self, forKey: .mimeType),
                text: try container.decodeIfPresent(String.self, forKey: .text)
            )
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let data, let mimeType, let metadata):
            try container.encode("image", forKey: .type)
            try container.encode(data, forKey: .data)
            try container.encode(mimeType, forKey: .mimeType)
            try container.encodeIfPresent(metadata, forKey: .metadata)
        case .audio(let data, let mimeType):
            try container.encode("audio", forKey: .type)
            try container.encode(data, forKey: .data)
            try container.encode(mimeType, forKey: .mimeType)
        case .resource(let uri, let mimeType, let text):
            try container.encode("resource", forKey: .type)
            try container.encode(uri, forKey: .uri)
            try container.encodeIfPresent(mimeType, forKey: .mimeType)
            try container.encodeIfPresent(text, forKey: .text)
        }
    }
}
