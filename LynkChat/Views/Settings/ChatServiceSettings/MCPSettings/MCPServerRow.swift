import SwiftUI

struct MCPServerRow: View {
    let server: MCPServer
    @Environment(MCPConfigVM.self) var configVM
    
    @State var selectedServer: MCPServer?
    
    var body: some View {
        Button {
            selectedServer = server
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(server.name).font(.headline)
                        Text(server.type.displayName)
                            .font(.caption)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.background.tertiary, in: .rect(cornerRadius: 4))
                    }
                    Text(server.url)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    if !server.isValid {
                        Label("Invalid configuration", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .labelStyle(.iconOnly)
                    }
                }
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { configVM.isServerEnabled(server.id) },
                    set: { _ in configVM.toggleServerEnabled(server.id) }
                ))
                .toggleStyle(.switch)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sheet(item: $selectedServer) { server in
            MCPServerDetailView(server: server)
        }
    }
}
