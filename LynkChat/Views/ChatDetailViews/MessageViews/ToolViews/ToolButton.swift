//
//  ToolButton.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolButton: View {
    var chatTool: ChatTool
    var skipPrettyPrinting: Bool = true
    
    @State private var showArguments = false
    @Namespace private var transition
    
    var body: some View {
        Button {
            showArguments.toggle()
        } label: {
            Label(chatTool.tool.title, systemImage: chatTool.tool.iconName)
                .fontWeight(.semibold)
                .foregroundStyle(chatTool.tool.color)
        }
        .buttonStyle(.bordered)
        #if os(macOS)
        .controlSize(.large)
        #endif
        .buttonBorderShape(.roundedRectangle)
        .popover(isPresented: $showArguments) {
            ScrollView {
                if skipPrettyPrinting {
                    Text(LocalizedStringKey(chatTool.args))
                        .textSelection(.enabled)
                } else {
                    if let prettyJSON = prettyPrintJSON(chatTool.args) {
                        Text(prettyJSON)
                            .textSelection(.enabled)
                    } else {
                        Text(chatTool.args)
                            .textSelection(.enabled)
                    }
                }
            }
            .presentationDragIndicator(.visible)
            .navigationTransition(.zoom(sourceID: "toolbutton-popover", in: transition))
            .presentationDetents([.medium])
            .contentMargins(20, for: .scrollContent)
            .frame(maxWidth: 400)
        }
        .matchedTransitionSource(id: "toolbutton-popover", in: transition)
    }
    
    func prettyPrintJSON(_ jsonString: String) -> String? {
        do {
            // Convert string to data
            guard let jsonData = jsonString.data(using: .utf8) else {
                return nil
            }
            
            // Parse JSON data
            let parsedJSON = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // Convert back to data with pretty printing
            let prettyPrintedData = try JSONSerialization.data(withJSONObject: parsedJSON, options: [.prettyPrinted])
            
            // Convert pretty printed data back to string
            return String(data: prettyPrintedData, encoding: .utf8)
        } catch {
            print("Error formatting JSON: \(error)")
            return nil
        }
    }
}

#Preview {
    ToolButton(chatTool: .mockTool)
}
