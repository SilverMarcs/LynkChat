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
    @State private var editingServer: MCPServer?
    
    var body: some View {
        List {
            ForEach($servers) { $server in
                MCPServerRow(server: $server, onEdit: {
                    editingServer = server
                })
            }
            .onDelete { indexSet in
                servers.remove(atOffsets: indexSet)
            }
            .onMove { source, destination in
                servers.move(fromOffsets: source, toOffset: destination)
            }
            
            if servers.isEmpty {
                ContentUnavailableView {
                    Label("No MCP Servers", systemImage: "server.rack")
                } description: {
                    Text("Add MCP servers to extend functionality")
                } actions: {
                    Button("Add Server") {
                        showingAddServer = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("MCP Servers")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddServer = true
                } label: {
                    Label("Add Server", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    servers.append(contentsOf: MCPServer.examples)
                } label: {
                    Label("Add Examples", systemImage: "doc.on.doc")
                }
            }
            
            #if !os(macOS)
            ToolbarItem(placement: .secondaryAction) {
                EditButton()
            }
            #endif
        }
        .sheet(isPresented: $showingAddServer) {
            MCPServerEditView(server: .constant(MCPServer(name: "", type: .http, url: ""))) { newServer in
                servers.append(newServer)
                showingAddServer = false
            }
        }
        .sheet(item: $editingServer) { server in
            if let index = servers.firstIndex(where: { $0.id == server.id }) {
                MCPServerEditView(server: $servers[index]) { _ in
                    editingServer = nil
                }
            }
        }
    }
}

struct MCPServerRow: View {
    @Binding var server: MCPServer
    var onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(server.name)
                        .font(.headline)
                    
                    Text(server.type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Text(server.url)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                
                if !server.isValid {
                    Label("Invalid configuration", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}

struct MCPServerEditView: View {
    @Binding var server: MCPServer
    var onSave: (MCPServer) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var type: MCPServer.MCPServerType
    @State private var url: String
    @State private var headersText: String
    
    init(server: Binding<MCPServer>, onSave: @escaping (MCPServer) -> Void) {
        self._server = server
        self.onSave = onSave
        
        _name = State(initialValue: server.wrappedValue.name)
        _type = State(initialValue: server.wrappedValue.type)
        _url = State(initialValue: server.wrappedValue.url)
        
        // Convert headers dict to text
        var headersStr = ""
        if let headers = server.wrappedValue.headers {
            headersStr = headers.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        }
        _headersText = State(initialValue: headersStr)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Server Name", text: $name)
                    
                    Picker("Type", selection: $type) {
                        ForEach(MCPServer.MCPServerType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("HTTP Configuration") {
                    TextField("URL", text: $url)
                        .font(.body.monospaced())
//                            .autocapitalization(.none)
                    
                    VStack(alignment: .leading) {
                        Text("Headers (format: KEY: VALUE, one per line)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $headersText)
                            .font(.body.monospaced())
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(server.name.isEmpty ? "New MCP Server" : "Edit Server")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveServer()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        switch type {

        case .http:
            return !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    private func saveServer() {
        var updatedServer = server
        updatedServer.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedServer.type = type
        
        switch type {
        case .http:
            updatedServer.url = url.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var headers: [String: String] = [:]
            let headerLines = headersText.components(separatedBy: .newlines)
            for line in headerLines {
                let parts = line.split(separator: ":", maxSplits: 1)
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                    if !key.isEmpty && !value.isEmpty {
                        headers[key] = value
                    }
                }
            }
            
            updatedServer.headers = headers.isEmpty ? nil : headers

        }
        
        server = updatedServer
        onSave(updatedServer)
        dismiss()
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
