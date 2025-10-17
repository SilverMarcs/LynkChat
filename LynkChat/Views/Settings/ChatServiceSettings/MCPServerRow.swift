import SwiftUI

struct MCPServerRow: View {
    let server: MCPServer
    
    var body: some View {
        NavigationLink(destination: MCPServerDetailView(server: server)) {
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
            .contentShape(.rect)
        }
    }
}
