//
//  AudioFileAPI.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import Foundation

struct FileIOResponse: Codable {
    let success: Bool
    let key: String
    
    static func uploadAudioFile(_ audioData: Data) async throws -> String {
        let url = URL(string: "https://file.io")!
        var request = URLRequest(url: url)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        // TODO: get this from server afte rinitial app launch instead of hardcoding.
        request.setValue("Bearer TJDXQJL.K9QNEE9-8FG48BB-KFT3RC3-TYRHM91", forHTTPHeaderField: "Authorization")
        
        var body = Data()
        
        // Add the audio file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.mp3\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/mpeg\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(FileIOResponse.self, from: data)
        return response.key
    }
}
