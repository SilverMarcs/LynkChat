//
//  ChatModelTable.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ChatModelTable: View {
    @StateObject private var modelConfig = ModelConfig.shared
    @State private var selection: ChatModel.ID?
    
    var body: some View {
        Form {
            Table(ChatModel.allCases, selection: $selection) {
                TableColumn("Model", value: \.name)
                TableColumn("Enabled") { model in
                    Toggle("", isOn: modelConfig.binding(for: model))
                        .labelsHidden()
                }
            }
        }
        .formStyle(.grouped)
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    ChatModelTable()
}
