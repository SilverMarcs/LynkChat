//
//  MaxTokens.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import Foundation

enum MaxTokens: Int, CaseIterable, Codable {
    case t512 = 512
    case t1024 = 1024
    case t2048 = 2048
    case t4096 = 4096
    case t8192 = 8192
    
    var description: String {
        return String(self.rawValue)
    }
}
