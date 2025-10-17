import SwiftUI

struct MCPServerAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MCPConfigVM.self) private var configVM
    
    @State private var name: String = ""
    @State private var url: String = ""
    @State private var headers: [HeaderItem] = []
    @State private var isLoading = false
    
    struct HeaderItem: Identifiable {
        let id = UUID()
        var key: String
        var value: String
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Server Name", text: $name)
                }
                
                Section("Connection") {
                    TextField("URL", text: $url)
                        .font(.body.monospaced())
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                    
                    Picker("Type", selection: .constant("HTTP")) {
                        Text("HTTP")
                            .tag("HTTP")
                    }
                }
                
                Section {
                    ForEach($headers) { $header in
                        HStack {
                            VStack(spacing: 8) {
                                TextField("Key", text: $header.key)
                                    .font(.body.monospaced())
                                    #if os(iOS)
                                    .textInputAutocapitalization(.never)
                                    #endif
                                Divider()
                                TextField("Value", text: $header.value)
                                    .font(.body.monospaced())
                                    #if os(iOS)
                                    .textInputAutocapitalization(.never)
                                    #endif
                            }
                            Spacer()
                            
                            Button(role: .destructive) {
                                headers.removeAll { $0.id == header.id }
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                } header: {
                    Text("Headers")
                } footer: {
                    Button(action: { headers.append(HeaderItem(key: "", value: "")) }) {
                        Label("Add Header", systemImage: "plus")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Add MCP Server")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isLoading ? "Adding..." : "Add", action: addServer)
                        .disabled(!isValid || isLoading)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !url.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func addServer() {
        isLoading = true
        
        let headerDict = headers
            .filter { !$0.key.trimmingCharacters(in: .whitespaces).isEmpty }
            .reduce(into: [String: String]()) {
                let key = $1.key.trimmingCharacters(in: .whitespaces)
                let value = $1.value.trimmingCharacters(in: .whitespaces)
                if !key.isEmpty && !value.isEmpty {
                    $0[key] = value
                }
            }

        var newServer = MCPServer(
            name: name.trimmingCharacters(in: .whitespaces),
            url: url.trimmingCharacters(in: .whitespaces),
            headers: headerDict.isEmpty ? nil : headerDict,
        )
        
        Task {
            do {
                let tools = try await MCPToolAdapter.listToolsForServer(server: newServer)
                newServer.tools = tools
                configVM.addServer(newServer)
                dismiss()
            } catch {
                isLoading = false
            }
        }
    }
}
