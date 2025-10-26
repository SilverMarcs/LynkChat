//
//  ImageConfig.swift
//  LynkChat
//
//  Created by Codex on 27/10/2025.
//

import Foundation

struct ImageConfig: Hashable, Codable {
    var generationModel: ImageModel
    var editModel: ImageEditingModel

    init(defaults: ImageConfigDefaults = .init()) {
        self.generationModel = defaults.defaultModel
        self.editModel = defaults.defaultEditingModel
    }
}

