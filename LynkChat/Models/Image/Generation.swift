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

    var isProcessing: Bool = false
    
    @Relationship(deleteRule: .nullify)
    var config: ImageConfig
    
    var image: Data? = nil
    
    @Transient
    var generatingTask: Task<Void, Error>?

    init(config: ImageConfig, session: ImageSession) {
        self.config = config
        self.session = session
    }
    
    @MainActor
    func send() async {
        isProcessing = true
        defer { isProcessing = false }

        generatingTask = Task { @MainActor in
            let dataObjects: [Data]
            if session.inputImages.isEmpty {
                dataObjects = try await APIService.generateImages(config: config)
            } else {
                dataObjects = try await ImageEditingService.editImages(
                    using: config.editingModel,
                    prompt: config.prompt,
                    inputImages: session.inputImages
                )
            }

            self.image = dataObjects.first
        }

        do {
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
            deleteSelf()
        }
    }
    
    func deleteSelf() {
        session.deleteGeneration(self)
    }
}
