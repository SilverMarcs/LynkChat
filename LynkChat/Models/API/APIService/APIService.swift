//
//  APIService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/08/2025.
//

import Foundation

enum APIService {
    static func makeRequest(path: APIPath, method: HTTPMethod) -> URLRequest? {
        guard let url = URL(string: "\(String.apiHost)\(path.pathString)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(AppConfig().myApiKey, forHTTPHeaderField: "x-api-key")
        
        if method == .POST && path != .upload {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    // Centralized error handling method
    static func handleAPIResponse(data: Data, response: URLResponse, context: String = "") throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RuntimeError("Invalid response")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            AppLogger.critical("\(context) error response: \(String(data: data, encoding: .utf8) ?? "Unable to read error data")")
            
            let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw RuntimeError(errorResponse.error)
        }
    }
    
    // Generic method for making API calls with automatic error handling
    static func performRequest<T: Codable>(
        path: APIPath,
        method: HTTPMethod,
        body: Encodable? = nil,
        responseType: T.Type,
        context: String = ""
    ) async throws -> T {
        guard var request = makeRequest(path: path, method: method) else {
            throw URLError(.badURL)
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleAPIResponse(data: data, response: response, context: context)
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum HTTPMethod: String {
    case POST
    case GET
    case DELETE
}

enum APIPath {
    case chat
    case title
    case image
    case upload
    case list
    case delete
    
    var pathString: String {
        switch self {
        case .chat:
            return "/chat"
        case .title:
            return "/chat/title"
        case .image:
            return "/image"
        case .upload:
            return "/chat/rag/upload"
        case .list:
            return "/chat/rag/list"
        case .delete:
            return "/chat/rag/delete"
        }
    }
}
