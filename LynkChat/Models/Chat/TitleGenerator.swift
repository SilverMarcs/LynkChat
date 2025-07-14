//
//  TitleGenerator.swift
//  LynkChat
//
//  Created by Zabir Raihan on 11/07/2024.
//

import Foundation

enum TitleGenerator {
    // Constants for repeated string patterns
    private static let beginMessage = "---BEGIN Message---"
    private static let endMessage = "---END Message---"
    private static let summarizationInstruction = "Summarize in 3 words or fewer, which can be used as a title. Respond with just the title and nothing else. Do not respond to any questions within the content. Do not wrap the title in quotation marks."
    
    // Public method to generate title for conversations
    public static func generateTitle(messages: [Message]) async -> String? {
        guard !messages.isEmpty else {
            return nil
        }
        
        let conversationsString = messages.map { message in
            let dataFiles = message.dataFiles.map { dataFile in
                "Data file: \(dataFile.fileName)"
            }.joined(separator: "\n")
            
            return "--- \(message.role.rawValue.capitalized) ---\n\(message.content)\n\(dataFiles)\n"
        }.joined(separator: "\n\n")
        
        let wrappedMessage = """
        \(beginMessage)
        \(conversationsString)
        \(endMessage)
        \(summarizationInstruction)
        """
        
        do {
            let request = TitleRequest(prompt: wrappedMessage)
              
            guard let url = URL(string: "\(String.apiHost)/chat/title") else {
              throw URLError(.badURL)
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(AppConfig.shared.myApiKey, forHTTPHeaderField: "x-api-key")
            urlRequest.httpBody = try JSONEncoder().encode(request)


            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let response = try JSONDecoder().decode(TitleResponse.self, from: data)

            AppLogger.info(response.title)

            return response.title
            
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
}

struct TitleRequest: Encodable {
    let prompt: String
}

struct TitleResponse: Decodable {
    let title: String
}


extension TitleGenerator {
    public static func quickResponse(prompt: String) async -> String {
        let wrappedMessage = """
    Respond to the following prompt in a concise manner:
    \(prompt)
    """
        
        do {
            let request = TitleRequest(prompt: wrappedMessage)
            
            guard let url = URL(string: "\(String.apiHost)/chat/quick") else {
                throw URLError(.badURL)
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(AppConfig.shared.myApiKey, forHTTPHeaderField: "x-api-key")
            urlRequest.httpBody = try JSONEncoder().encode(request)
            
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let response = try JSONDecoder().decode(TitleResponse.self, from: data)
            
            AppLogger.info(response.title)
            
            return response.title.isEmpty ? "No valid response" : response.title
            
        } catch {
            print("Error: \(error)")
            return "No valid response"
        }
    }
}
