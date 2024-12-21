//
//  HTTPScheme.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/11/2024.
//

import Foundation

enum HTTPScheme: String, Codable, CaseIterable, Hashable, Identifiable {
    var id: String { rawValue }
    
    case http
    case https
}
