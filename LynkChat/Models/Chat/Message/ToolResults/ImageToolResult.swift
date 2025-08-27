//
//  ImageToolResult.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/08/2025.
//

import Foundation

struct ImageResult: Codable {
    let imageData: Data?
    let mediaType: String
    let id: UUID
    
    private enum CodingKeys: String, CodingKey {
        case data
        case mediaType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataString = try container.decode(String.self, forKey: .data)
        self.imageData = Data(base64Encoded: dataString)
        self.mediaType = try container.decode(String.self, forKey: .mediaType)
        self.id = UUID()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let imageData = self.imageData {
            let dataString = imageData.base64EncodedString()
            try container.encode(dataString, forKey: .data)
        }
        try container.encode(self.mediaType, forKey: .mediaType)
    }
}

struct ImageToolResult: Codable {
    let images: [ImageResult]
}
