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
                TableColumn("On") { model in
                    Toggle("Show", isOn: modelConfig.binding(for: model))
                        .labelsHidden()
                }
                .width(30)
                .alignment(.center)
                
                TableColumn("Model") { model in
                    HStack {
                        ModelImage(model: model)
                        Text(model.name)
                    }
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
