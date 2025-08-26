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
        request.setValue(AppConfig.shared.myApiKey, forHTTPHeaderField: "x-api-key")
        
        if method == .POST && path != .upload {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
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
