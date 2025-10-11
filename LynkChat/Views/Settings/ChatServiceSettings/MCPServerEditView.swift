//
//  MCPServerEditView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 11/10/2025.
//

import SwiftUI

struct MCPServerEditView: View {
    @Binding var server: MCPServer
    var onSave: (MCPServer) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var type: MCPServer.MCPServerType
    @State private var url: String
    @State private var headers: [HeaderPair] = []
    
    struct HeaderPair: Identifiable {
        let id = UUID()
        var key: String
        var value: String
    }
    
    init(server: Binding<MCPServer>, onSave: @escaping (MCPServer) -> Void) {
        self._server = server
        self.onSave = onSave
        
        _name = State(initialValue: server.wrappedValue.name)
        _type = State(initialValue: server.wrappedValue.type)
        _url = State(initialValue: server.wrappedValue.url)
        
        // Convert headers dict to array
        var headerPairs: [HeaderPair] = []
        if let headers = server.wrappedValue.headers {
            headerPairs = headers.map { HeaderPair(key: $0.key, value: $0.value) }
        }
        _headers = State(initialValue: headerPairs)
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
                        #if !os(macOS)
                        .autocapitalization(.none)
                        #endif
                }
                
                Section {
                    ForEach($headers) { $header in
                        HStack {
                            VStack(spacing: 8) {
                                TextField("Key", text: $header.key)
                                    .font(.body.monospaced())
#if !os(macOS)
                                    .autocapitalization(.none)
#endif
                                
                                TextField("Value", text: $header.value)
                                    .font(.body.monospaced())
#if !os(macOS)
                                    .autocapitalization(.none)
#endif
                            }
                            
                            Spacer()
                            
                            Button(role: .destructive) {
                                deleteHeader(header)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    
                } header: {
                    Text("Headers")
                } footer: {
                    HStack {
                        Spacer()
                    
                        Button(action: addHeader) {
                            Label("Add Header", systemImage: "plus")
                        }
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
    
    private func addHeader() {
        headers.append(HeaderPair(key: "", value: ""))
    }
    
    private func deleteHeader(_ header: HeaderPair) {
        headers.removeAll { $0.id == header.id }
    }
    
    private func saveServer() {
        var updatedServer = server
        updatedServer.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedServer.type = type
        
        switch type {
        case .http:
            updatedServer.url = url.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var headersDict: [String: String] = [:]
            for header in headers {
                let key = header.key.trimmingCharacters(in: .whitespaces)
                let value = header.value.trimmingCharacters(in: .whitespaces)
                if !key.isEmpty && !value.isEmpty {
                    headersDict[key] = value
                }
            }
            
            updatedServer.headers = headersDict.isEmpty ? nil : headersDict
        }
        
        server = updatedServer
        onSave(updatedServer)
        dismiss()
    }
}
