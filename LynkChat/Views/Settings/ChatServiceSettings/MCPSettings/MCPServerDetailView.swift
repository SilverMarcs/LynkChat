import SwiftUI

struct MCPServerDetailView: View {
    let server: MCPServer
    @Environment(MCPConfigVM.self) var configVM
    
    var body: some View {
        Form {
            Section("Server Information") {
                LabeledContent("Name", value: server.name)
                LabeledContent("Type", value: server.type.displayName)
                LabeledContent("URL", value: server.url).font(.body.monospaced())
            }
            
            if let headers = server.headers, !headers.isEmpty {
                Section("Headers") {
                    ForEach(Array(headers), id: \.key) { key, value in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(key).font(.caption).foregroundStyle(.secondary)
                            Text(value).font(.body.monospaced()).lineLimit(1)
                        }
                    }
                }
            }
            
            Section("Tools") {
                ForEach(server.tools, id: \.id) { tool in
                    DisclosureGroup(tool.name) {
                        Text(tool.description ?? "No description")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            // TODO: refresh tools
        }
        .formStyle(.grouped)
        .navigationTitle("Server Details")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Toggle(isOn: Binding(
                    get: { configVM.isServerEnabled(server.id) },
                    set: { configVM.toggleServerEnabled(server.id, enabled: $0) }
                )) {
                    Label("Default", systemImage: "checkmark")
                        .labelStyle(.titleOnly)
                }
            }
        }
    }
}
