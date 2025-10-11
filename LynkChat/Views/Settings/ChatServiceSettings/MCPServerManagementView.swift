//
//  MCPServerManagementView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 11/10/2025.
//

import SwiftUI

struct MCPServerManagementView: View {
    @Binding var servers: [MCPServer]
    @State private var showingAddServer = false
    
    var body: some View {
        List {
            ForEach($servers) { $server in
                MCPServerRow(server: $server)
            }
            .onDelete { indexSet in
                servers.remove(atOffsets: indexSet)
            }
        }
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
                servers.append(newServer)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MCPServerManagementView(servers: .constant([
            MCPServer.examples[0],
            MCPServer.examples[1]
        ]))
    }
}
