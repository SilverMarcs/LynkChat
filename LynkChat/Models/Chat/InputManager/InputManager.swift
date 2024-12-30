//
//  InputManager.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI

enum InputState {
    case normal
    case editing
}

@Observable class InputManager {
    var state: InputState = .normal
    
    var normalPrompt: String = ""
    var editingPrompt: String = ""
    
    var tempNormalPrompt: String = ""
    var tempNormalDataFiles: [TypedData] = []
    
    var normalDataFiles: [TypedData] = []
    var editingDataFiles: [TypedData] = []
    
    var editingMessage: Message?
    
    var prompt: String {
        get { state == .normal ? normalPrompt : editingPrompt }
        set {
            if state == .normal {
                normalPrompt = newValue
            } else {
                editingPrompt = newValue
            }
        }
    }
    
    var dataFiles: [TypedData] {
        get { state == .normal ? normalDataFiles : editingDataFiles }
        set {
            if state == .normal {
                normalDataFiles = newValue
            } else {
                editingDataFiles = newValue
            }
        }
    }
    
    func setupEditing(message: MessageGroup) {
        withAnimation {
            state = .editing
            Scroller.scroll(to: .top, of: message, animated: true)
        }
        
        tempNormalPrompt = normalPrompt
        tempNormalDataFiles = normalDataFiles
        
        editingMessage = message.activeMessage
        prompt = message.content
        dataFiles = message.dataFiles
    }
    
    func reset() {
        state = .normal
        editingMessage = nil
        prompt = tempNormalPrompt
        dataFiles = tempNormalDataFiles
    }
}

// MARK: - Drag and Drop

