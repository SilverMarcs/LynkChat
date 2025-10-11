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
    
    init(config: Binding<ChatConfig>) {
        self._config = config
        _availableServers = State(initialValue: ChatConfigDefaults().mcpServers)
    }
    
    var body: some View {
        ControlGroup {
            ForEach(availableServers) { server in
                Toggle(isOn: Binding(
                    get: { config.isMCPServerEnabled(server.id) },
                    set: { _ in config.toggleMCPServer(server.id) }
                )) {
                    HStack {
                        Text(server.name)
                        
                        Text(server.type.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.background.secondary, in: .rect(cornerRadius: 4))
                    }
                }
            }
        } label: {
            Label("MCP Servers", systemImage: "puzzlepiece")
        }
    }
}
