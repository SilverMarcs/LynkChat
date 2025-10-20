//
//  ImageModelSelector.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

enum ImageModelSelector {
    static func selectMode(prompt: String, history: [Generation], hasInputImages: Bool) async -> GenerationMode {
        // If user attached images, always editing per requirement
        if hasInputImages { return .editing }

        return heuristic(prompt: prompt)
    }

    private static func heuristic(prompt: String) -> GenerationMode {
        let lower = prompt.lowercased()
        let editingHints = [
            "edit", "make", "change", "replace", "remove", "add", "erase", "fix",
            "background", "color", "enhance", "retouch", "touch up", "adjust", "increase",
            "decrease", "crop", "blur", "sharpen"
        ]
        return editingHints.contains(where: { lower.contains($0) }) ? .editing : .generation
    }
}
