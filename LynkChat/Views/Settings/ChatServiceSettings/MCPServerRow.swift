//
//  MCPServerRow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 11/10/2025.
//

import SwiftUI

struct MCPServerRow: View {
    @Binding var server: MCPServer
    @Binding var isDefaultEnabled: Bool
    @State var showEditSheet: Bool = false
    
    var body: some View {
        Button {
            showEditSheet = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(server.name)
                            .font(.headline)
                        
                        Text(server.type.displayName)
                            .font(.caption)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.background.tertiary, in: .rect(cornerRadius: 4))
                    }
                    
                    Text(server.url)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    
                    if !server.isValid {
                        Label("Invalid configuration", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .labelStyle(.iconOnly)
                    }
                }
                
                Spacer()
                
                Toggle("Default", isOn: $isDefaultEnabled)
                    .labelsHidden()
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showEditSheet) {
            MCPServerEditView(server: $server) { server in
                
            }
        }
    }
}
