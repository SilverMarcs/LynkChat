//
//  RefreshModelRow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import SwiftUI

private struct RefreshModelRow: View {
    let model: GenericModel
    let isSelected: Binding<Bool>

    var body: some View {
        HStack {
            Toggle(isOn: isSelected) {
                VStack(alignment: .leading) {
                    Text(model.code)
                        .monospaced()
                    Text(model.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "quote.bubble")
        }
    }
}
