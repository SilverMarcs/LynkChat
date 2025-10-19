//
//  ToolButton.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolButton: View {
    var chatTool: ChatTool
    
    @State private var showArguments = false
    
    var body: some View {
        Button {
            showArguments.toggle()
        } label: {
            Label(chatTool.toolName, systemImage: "puzzlepiece")
                .fontWeight(.semibold)
                .foregroundStyle(.green)
        }
        .labelStyle(.titleAndIcon)
        .buttonStyle(.bordered)
        #if os(macOS)
        .controlSize(.large)
        #endif
        .buttonBorderShape(.roundedRectangle)
        .popover(isPresented: $showArguments) {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Text(prettyPrintJSON(chatTool.args))
                    Divider()
                    Text(prettyPrintJSON(chatTool.result ?? "Failed to get results"))
                        .textSelection(.enabled)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium])
            .contentMargins(20, for: .scrollContent)
            #if os(macOS)
            .frame(width: 500, height: 500)
            #endif
        }
    }
    
    private func prettyPrintJSON(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString // Return original if parsing fails
        }
        return prettyString
    }
}
