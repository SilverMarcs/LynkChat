//
//  ImageKit.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import Foundation

private struct ImageKitResponse: Codable {
    let url: String
    // We're not declaring other fields since we don't need them
    
    // This allows us to decode JSON even with fields we haven't declared
    private enum CodingKeys: String, CodingKey {
        case url
    }
}

enum ImageKit {
    static func uploadFile(data: TypedData) async throws -> String {
        let endpoint = URL(string: "https://upload.imagekit.io/api/v1/files/upload")!
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        
        // Set up authentication
        let apiKey = "private_3JH/UKjWOw20pzrQnBS0VQM8c78="
        let authString = "\(apiKey):"
        let authData = authString.data(using: .utf8)!
        let base64Auth = authData.base64EncodedString()
        request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var bodyData = Data()
        
        // Add file data
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(data.fileName)\"\r\n".data(using: .utf8)!)
        bodyData.append("Content-Type: \(data.fileType.preferredMIMEType ?? "application/octet-stream")\r\n\r\n".data(using: .utf8)!)
        bodyData.append(data.data)
        bodyData.append("\r\n".data(using: .utf8)!)
        
        // Add filename field
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"fileName\"\r\n\r\n".data(using: .utf8)!)
        bodyData.append("\(data.fileName)".data(using: .utf8)!)
        bodyData.append("\r\n".data(using: .utf8)!)
        
        // Add closing boundary
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = bodyData
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        // Print raw JSON response
        if let jsonString = String(data: responseData, encoding: .utf8) {
            print("Raw JSON Response:")
            print(prettyPrintJSON(jsonString))
        }
        
        // Decode only the URL from the response
        let response = try JSONDecoder().decode(ImageKitResponse.self, from: responseData)
        return response.url
    }
    
    private static func prettyPrintJSON(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        return prettyString
    }
}
