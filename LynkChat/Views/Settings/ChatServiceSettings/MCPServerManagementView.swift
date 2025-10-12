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
                let isDefaultEnabled = Binding<Bool>(
                    get: { self.config.defaultEnabledMCPServerIds.contains(server.id) },
                    set: { isOn in
                        if isOn {
                            self.config.defaultEnabledMCPServerIds.insert(server.id)
                        } else {
                            self.config.defaultEnabledMCPServerIds.remove(server.id)
                        }
                    }
                )
                
                MCPServerRow(server: $server, isDefaultEnabled: isDefaultEnabled)
                    .contextMenu {
                        Button(role: .destructive) {
                            if let index = self.config.mcpServers.firstIndex(where: { $0.id == server.id }) {
                                self.config.mcpServers.remove(at: index)
                                self.config.defaultEnabledMCPServerIds.remove(server.id)
                                self.trigger += 1
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
