//
//  MessageRole.swift
//  LynkChat
//
//  Created by Zabir Raihan on 10/07/2024.
//

import Foundation

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
    case tool
}
