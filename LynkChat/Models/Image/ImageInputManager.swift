//
//  ImageInputManager.swift
//  LynkChat
//
//  Created by Zabir Raihan on 10/10/2025.
//

import Foundation
import SwiftUI

@Observable
class ImageInputManager {
    var inputImages: [Data] = []
    var prompt: String = ""
    
    func addImage(_ imageData: Data) {
        inputImages.append(imageData)
    }
    
    func removeImage(at index: Int) {
        guard index < inputImages.count else { return }
        inputImages.remove(at: index)
    }
    
    func clearImages() {
        inputImages.removeAll()
    }
    
    func setPrompt(_ newPrompt: String) {
        prompt = newPrompt
    }
}
