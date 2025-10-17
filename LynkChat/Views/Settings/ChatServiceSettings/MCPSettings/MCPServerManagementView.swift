import SwiftUI

struct MCPServerManagementView: View {
    @Environment(MCPConfigVM.self) var configVM
    @State private var showingAddServer = false
    
    var body: some View {
        Form {
            ForEach(configVM.mcpServers, id: \.id) { server in
                MCPServerRow(server: server)
                    .contextMenu {
                        Button(role: .destructive) {
                            configVM.removeServer(withId: server.id)
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
                Button(action: { showingAddServer = true }) {
                    Label("Add Server", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddServer) {
            MCPServerAddView()
        }
    }
}
