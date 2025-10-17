//
//  MCPServerManagementView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 11/10/2025.
//

import SwiftUI

struct MCPServerManagementView: View {
    @Environment(MCPConfigVM.self) var configVM
    @State private var showingAddServer = false
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach(configVM.mcpServers.indices, id: \.self) { index in
                    let isDefaultEnabled = Binding<Bool>(
                        get: { configVM.isServerEnabled(configVM.mcpServers[index].id) },
                        set: { isOn in
                            configVM.toggleServerEnabled(configVM.mcpServers[index].id, enabled: isOn)
                        }
                    )
                    
                    MCPServerRow(server: Binding(
                        get: { configVM.mcpServers[index] },
                        set: { configVM.mcpServers[index] = $0 }
                    ), isDefaultEnabled: isDefaultEnabled)
                        .contextMenu {
                            Button(role: .destructive) {
                                configVM.removeServer(withId: configVM.mcpServers[index].id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .formStyle(.grouped)
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
                NavigationStack {
                    MCPServerEditView(server: .constant(MCPServer(name: "", type: .http, url: ""))) { newServer in
                        configVM.addServer(newServer)
                    }
                }
            }
        }
    }
}
