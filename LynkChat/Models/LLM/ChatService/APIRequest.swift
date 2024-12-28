//
//  APIRequest.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

// TODO: make init that must check whether able to send own api key or not.
struct APIRequest: Encodable {
    let model: String
    let messages: [APIMessage]
    let system: String?
    let stream: Bool
    
    init(model: String, messages: [APIMessage], system: String?, stream: Bool) {
        self.model = model
        self.messages = messages
        self.system = system
        self.stream = stream
    }
}
