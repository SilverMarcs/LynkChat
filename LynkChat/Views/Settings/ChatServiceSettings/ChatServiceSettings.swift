import SwiftUI

struct ChatServiceSettings: View {
    @State private var selectedTab: ChatServiceTab = .general
    
    enum ChatServiceTab: String, CaseIterable {
        case general = "General"
        case providers = "Models"
        case mcp = "MCP"
    }
    
    var body: some View {
        Group {
            switch selectedTab {
            case .general:
                GeneralChatSettings()
            case .providers:
                ProvidersSettings()
            case .mcp:
                MCPServerManagementView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Settings", selection: $selectedTab) {
                    ForEach(ChatServiceTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

#Preview {
    ChatServiceSettings()
}
