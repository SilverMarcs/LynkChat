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
        Group {
#if os(macOS)
            macOS
#else
            iOS
#endif
        }
        // TODO: Toolbar info icon for extra info
    }
    
    var macOS: some View {
        Form {
            Section {
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
                    
                    TableColumn("Tool") { model in
                        Image(systemName: model.supportsTool ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(model.supportsTool ? .green : .red)
                    }
                    .alignment(.center)
                    
                    TableColumn("Price") { model in
                        Text("\(model.price.promptTokens) / \(model.price.completionTokens)")
                    }
                    .alignment(.trailing)
                }
            } footer: {
                SectionFooterView(text: "Prices are for per million tokens for input / output tokens")
            }
        }
        .formStyle(.grouped)
        .toolbarTitleDisplayMode(.inline)
    }
        
    
    var iOS: some View {
        List {
            Section("Models") {
                ForEach(ChatModel.allCases) { model in
                    HStack {
                        ModelImage(model: model)
                        Text(model.name)
                        
                        Spacer()
                        
                        Toggle("Show", isOn: modelConfig.binding(for: model))
                            .labelsHidden()
                    }
                }
            }
        }
    }
}

#Preview {
    ChatModelTable()
}
