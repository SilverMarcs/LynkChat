//
//  MCPServersToggleView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 11/10/2025.
//

import SwiftUI

struct MCPServersToggleView: View {
    @Binding var config: ChatConfig
    @State private var availableServers: [MCPServer] = []
    
    var body: some View {
        Group {
            if availableServers.isEmpty {
                HStack {
                    Text("No MCP servers configured")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Spacer()
                }
            } else {
                ForEach(availableServers) { server in
                    Toggle(isOn: Binding(
                        get: { config.isMCPServerEnabled(server.id) },
                        set: { _ in config.toggleMCPServer(server.id) }
                    )) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(server.name)
                                        .font(.body)
                                    
                                    Text(server.type.displayName)
                                        .font(.caption2)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.secondary.opacity(0.2))
                                        .cornerRadius(3)
                                }
                                
                                Text(server.url)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            availableServers = ChatConfigDefaults().mcpServers
        }
    }
}

#Preview {
    Form {
        Section("MCP Servers") {
            MCPServersToggleView(config: .constant(ChatConfig()))
        }
    }
}
