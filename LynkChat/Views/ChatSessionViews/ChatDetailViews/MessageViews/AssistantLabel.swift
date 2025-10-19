//
//  AssistantLabel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 01/12/2024.
//

import SwiftUI

struct AssistantLabel: View {
    @Environment(\.colorScheme) var colorScheme
    var model: ModelImageProvider
    
    var body: some View {
        Label {
            Text(model.name)
                .font(.subheadline)
                .bold()
                .foregroundStyle(.secondary)
                .foregroundStyle(Color(hex: model.color))
                .brightness(colorScheme == .dark ? 1.1 : -0.5)
        } icon: {
            Image(model.imageName)
                .imageScale(.large)
                .foregroundStyle(Color(hex: model.color).gradient)
        }
        .labelIconToTitleSpacing(5)
    }
}
