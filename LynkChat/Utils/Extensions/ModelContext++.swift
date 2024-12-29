//
//  ModelContext++.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import SwiftData

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            url
        } else {
            "No SQLite database found."
        }
    }
}
