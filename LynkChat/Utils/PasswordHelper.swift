//
//  PasswordHelper.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/01/2025.
//

import CryptoKit
import Foundation

enum PasswordHelper {
    private static let expectedHash = "52a58affa3bf134ac830cfac4eba8343"
    
    static func generateHash(from input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = Insecure.MD5.hash(data: inputData)
        return hashed.map { unsafe String(format: "%02x", $0) }.joined()
    }
    
    static func verifyPassword(_ input: String) -> Bool {
        let hashedInput = generateHash(from: input)
        return hashedInput == expectedHash
    }
}
