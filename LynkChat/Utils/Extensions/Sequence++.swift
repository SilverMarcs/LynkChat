//
//  Sequence++.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import Foundation

extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()
        for element in self {
            try await values.append(transform(element))
        }
        return values
    }
}
