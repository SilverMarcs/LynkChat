//
//  SettingsVM.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

@Observable class SettingsVM {
    static let shared = SettingsVM()
    
    var listState: ListState = .chats
    
    private init() {}
}

enum ListState: String, CaseIterable {
    case chats
    case images
    case search
    case settings
}
