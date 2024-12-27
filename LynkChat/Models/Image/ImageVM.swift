//
//  ImageVM.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData
import Foundation

@Observable class ImageVM {
    var searchText: String = ""
    var selections: Set<ImageSession> = []
    
    public var activeImageSession: ImageSession? {
        guard selections.count == 1 else { return nil }
        return selections.first
    }
    
    func sendGenerationRequest() {
        guard let session = activeImageSession else { return }
        Task {
            await session.send()
        }
    }
    
    func deleteLastGeneration() {
        guard let session = activeImageSession else { return }
        if let last = session.imageGenerations.last {
            last.deleteSelf()
        }
    }
}
