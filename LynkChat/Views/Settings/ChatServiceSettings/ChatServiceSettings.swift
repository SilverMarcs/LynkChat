import SwiftUI

struct ChatServiceSettings: View {
    @State private var selectedTab: ChatServiceTab = .general
    
    var body: some View {
        Group {
            switch selectedTab {
            case .general:
                GeneralChatSettings()
            case .models:
                ModelListSettings()
            case .mcp:
                MCPServerManagementView()
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Settings", selection: $selectedTab) {
                    ForEach(ChatServiceTab.allCases, id: \.self) { tab in
                        Label(tab.rawValue, systemImage: tab.imageName)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .controlSize(.large)
                .labelStyle(.titleOnly)
            }
        }
    }
}

#Preview {
    ChatServiceSettings()
}

enum ChatServiceTab: String, CaseIterable {
    case general = "General"
    case models = "Models"
    case mcp = "MCP"
    
    var imageName: String {
        switch self {
        case .general:
            return "gearshape"
        case .models:
            return "cube.box"
        case .mcp:
            return "server.rack"
        }
    }
}
