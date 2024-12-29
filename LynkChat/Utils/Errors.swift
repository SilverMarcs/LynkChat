//
//  Errors.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import Foundation

struct RuntimeError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}
