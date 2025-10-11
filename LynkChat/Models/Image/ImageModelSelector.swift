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

        // Try using Apple FoundationModels tool if available; otherwise use heuristic
        if let mode = await selectUsingFoundationModels(prompt: prompt, history: history) {
            return mode
        }
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

    private static func buildHistoryContext(history: [Generation], currentPrompt: String) -> String {
        var lines: [String] = []
        lines.append("You determine if a prompt requires image editing (modifying existing images) or image generation (creating new images). Use the selectImageModel tool.")
        for (idx, gen) in history.enumerated() {
            let step = idx + 1
            let mode = gen.mode.rawValue
            let prompt = gen.config.prompt.replacingOccurrences(of: "\n", with: " ")
            let userAdded = gen.inputImages.count
            let assistantOut = gen.images.count
            lines.append("Step #\(step): mode=\(mode), prompt=\"\(prompt)\", user_added_images=\(userAdded), assistant_output_images=\(assistantOut)")
        }
        lines.append("Current prompt: \(currentPrompt)")
        return lines.joined(separator: "\n")
    }

    private static func selectUsingFoundationModels(prompt: String, history: [Generation]) async -> GenerationMode? {
        #if canImport(FoundationModels)
        do {

            let model = SystemLanguageModel.default
            
            guard case .available = model.availability else {
                return nil
            }
            
            let session = LanguageModelSession(model: model) {
                buildHistoryContext(history: history, currentPrompt: prompt)
                """
                You are analyzing image-related requests. Determine if the user wants to:
                - 'editing': Modify, edit, or change an existing image
                - 'generation': Create a new image from scratch
                """
            }

            let response = try await session.respond(
                to: prompt,
                generating: ImageModeDecision.self
            )
            
            return response.content.mode == "editing" ? .editing : .generation
        } catch {
            print("Error selecting image mode: \(error)")
            return nil
        }
        #else
        return nil
        #endif
    }
    
    @Generable
    struct ImageModeDecision {
        @Guide(.anyOf(["editing", "generation"]))
        let mode: String    }
}
