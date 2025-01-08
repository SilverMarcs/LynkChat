//
//  PasswordHelper.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/01/2025.
//

import CryptoKit
import Foundation

enum PasswordHelper {
    // Store expected hash here after generating it
    private static let expectedHash = "52a58affa3bf134ac830cfac4eba8343"
    
    // Function to generate hash - use this to get hash of known password
    static func generateHash(from input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = Insecure.MD5.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
    
    // Function to verify password
    static func verifyPassword(_ input: String) -> Bool {
        let hashedInput = generateHash(from: input)
        return hashedInput == expectedHash
    }
}
