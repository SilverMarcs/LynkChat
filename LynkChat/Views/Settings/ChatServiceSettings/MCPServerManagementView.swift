//
//  MCPServerManagementView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 11/10/2025.
//

import SwiftUI

struct MCPServerManagementView: View {
    @State var config: ChatConfigDefaults = .init()
    @State private var showingAddServer = false
    @State private var trigger = 0
    
    var body: some View {
        Form {
            ForEach($config.mcpServers) { $server in
                MCPServerRow(server: $server)
                    .contextMenu {
                        Button(role: .destructive) {
                            if let index = config.mcpServers.firstIndex(where: { $0.id == server.id }) {
                                config.mcpServers.remove(at: index)
                                trigger += 1
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .formStyle(.grouped)
        .id(trigger)
        .navigationTitle("MCP Servers")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddServer = true
                } label: {
                    Label("Add Server", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddServer) {
            MCPServerEditView(server: .constant(MCPServer(name: "", type: .http, url: ""))) { newServer in
                config.mcpServers.append(newServer)
                trigger += 1
            }
        }
    }
}
