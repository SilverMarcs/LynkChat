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
        #if os(macOS)
        macOS
        #else
        iOS
        #endif
    }
    
    var macOS: some View {
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
