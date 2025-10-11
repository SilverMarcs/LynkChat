//
//  AnyDecodable.swift
//  LynkChat
//
//  Created by Zabir Raihan on 11/10/2025.
//

import Foundation

// MARK: - Helper for decoding any JSON
struct AnyDecodable: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: DynamicCodingKeys.self) {
            var dict = [String: Any]()
            for key in container.allKeys {
                dict[key.stringValue] = try container.decode(AnyDecodable.self, forKey: key).value
            }
            value = dict
        } else if var array = try? decoder.unkeyedContainer() {
            var arr = [Any]()
            while !array.isAtEnd {
                arr.append(try array.decode(AnyDecodable.self).value)
            }
            value = arr
        } else if let string = try? decoder.singleValueContainer().decode(String.self) {
            value = string
        } else if let int = try? decoder.singleValueContainer().decode(Int.self) {
            value = int
        } else if let double = try? decoder.singleValueContainer().decode(Double.self) {
            value = double
        } else if let bool = try? decoder.singleValueContainer().decode(Bool.self) {
            value = bool
        } else {
            value = NSNull()
        }
    }
}

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    var intValue: Int? { nil }
    init?(intValue: Int) { nil }
}
