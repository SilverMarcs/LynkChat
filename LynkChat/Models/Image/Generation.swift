//
//  Generation.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Generation {
    var id: UUID = UUID()
    var date: Date = Date()
    
    var session: ImageSession
    var imageModel: ImageModel?
    var imageEditingModel: ImageEditingModel?

    var isProcessing: Bool = false
    var isFailed: Bool = false
    
    @Relationship(deleteRule: .nullify)
    var config: ImageConfig
    
    var image: Data? = nil
    
    @Transient
    var generatingTask: Task<Void, Error>?

    init(config: ImageConfig, session: ImageSession) {
        self.config = config
        self.session = session

        if session.inputImages.isEmpty {
            imageModel = config.model
            imageEditingModel = nil
        } else {
            imageModel = nil
            imageEditingModel = config.editingModel
        }
    }

    var modelName: String {
        imageModel?.name ?? imageEditingModel?.name ?? "Unknown"
    }
    
    @MainActor
    func send() async {
        isProcessing = true
        defer { isProcessing = false }

        generatingTask = Task { [weak self] in
            guard let self else { return }
            let dataObjects: [Data]
            if let imageModel {
                var requestConfig = config
                requestConfig.model = imageModel
                dataObjects = try await ImageGenerationService.generateImages(config: requestConfig)
            } else if let imageEditingModel {
                dataObjects = try await ImageEditingService.editImages(
                    using: imageEditingModel,
                    prompt: config.prompt,
                    inputImages: session.inputImages
                )
            } else {
                isFailed = true
                return
            }

            self.image = dataObjects.first
        }

        do {
            defer { generatingTask = nil }
            #if os(macOS)
            try await generatingTask?.value
            #else
            let application = UIApplication.shared
            let taskId = application.beginBackgroundTask {
                // Handle expiration of background task here
            }

            try await generatingTask?.value

            application.endBackgroundTask(taskId)
            #endif
        } catch {
            print(error.localizedDescription)
            isFailed = true
        }
    }
    
    func deleteSelf() {
        session.deleteGeneration(self)
    }
}
