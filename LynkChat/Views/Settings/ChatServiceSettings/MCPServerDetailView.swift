import SwiftUI

struct MCPServerDetailView: View {
    @Binding var server: MCPServer
    @Environment(MCPConfigVM.self) var configVM
    @State private var showEditSheet = false
    @State private var isFetchingTools = false
    
    var body: some View {
        Form {
            Section("Server Information") {
                LabeledContent("Name", value: server.name)
                LabeledContent("Type", value: server.type.displayName)
                LabeledContent("URL", value: server.url)
                    .font(.body.monospaced())
            }
            
            if let headers = server.headers, !headers.isEmpty {
                Section("Headers") {
                    ForEach(Array(headers.sorted { $0.key < $1.key }), id: \.key) { key, value in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(key)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(value)
                                .font(.body.monospaced())
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            Section {
                if let tools = server.cachedTools, !tools.isEmpty {
                    ForEach(tools, id: \.name) { tool in
                        DisclosureGroup(tool.name) {
                            Text(tool.description ?? "No description")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else if !isFetchingTools {
                    Text("No tools cached")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Tools")
            } footer: {
                HStack {
                    Button(action: fetchTools) {
                        Label("Fetch Tools", systemImage: "opticaldiscdrive")

                    }
                    .disabled(isFetchingTools)
                    
                    Spacer()
                    
                    if let lastFetch = server.lastToolsFetchTime {
                        Text("Last fetched: \(lastFetch.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Server Details")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            MCPServerEditView(server: $server) { _ in }
        }
    }
    
    private func fetchTools() {
        isFetchingTools = true
        
        Task {
            do {
                let tools = try await MCPToolAdapter.listToolsForServer(server: server)
                
                server.cachedTools = tools
                server.lastToolsFetchTime = Date()
                
                if let index = configVM.mcpServers.firstIndex(where: { $0.id == server.id }) {
                    configVM.mcpServers[index] = server
                }
                
                isFetchingTools = false
            } catch {
                isFetchingTools = false
            }
        }
    }
}
