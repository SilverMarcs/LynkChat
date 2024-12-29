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
            GroupBox {
                HStack(spacing: 4) {
                    Text("Used")
                        .foregroundStyle(.secondary)

                    Text("\(chatTool.tool.title) \(Image(systemName: chatTool.tool.iconName))")
                        .fontWeight(.semibold)
                        .foregroundStyle(chatTool.tool.color)
                        .opacity(0.9)
                        
                }
                .padding(3)
            }
            .groupBoxStyle(PlatformGroupBoxStyle())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showArguments) {
            ScrollView {
                if let prettyJSON = prettyPrintJSON(chatTool.args) {
                    Text(prettyJSON)
                        .textSelection(.enabled)
                } else {
                    Text(chatTool.args)
                        .textSelection(.enabled)
                }
            }
            .safeAreaPadding()
            .frame(maxWidth: 400)
        }
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
