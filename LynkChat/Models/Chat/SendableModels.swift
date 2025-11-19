//
//  SendableModels.swift
//  LynkChat
//
//  Created by ChatGPT on 2025-09-19.
//

import Foundation

// These models are reference types managed on the main actor.
// They are accessed only from the chat streaming task hierarchy,
// so mark them as @unchecked Sendable to satisfy Swift 6 concurrency checks.
extension Chat: @unchecked Sendable { }
extension Message: @unchecked Sendable { }
extension MessageGroup: @unchecked Sendable { }

extension ImageSession: @unchecked Sendable { }
