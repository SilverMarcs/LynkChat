//
//  ProviderList.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct ProviderList: View {
    @Environment(\.modelContext) var modelContext
    @Query var providers: [Provider]
    @Query var providerDefaults: [ProviderDefaults]
    
    var body: some View {
        Group {
            #if os(macOS)
            Form {
                content
            }
            .formStyle(.grouped)
            #else
            content
            #endif
        }
        .toolbar {
            addButton
        }
    }
    
    var content: some View {
        List {
            ForEach(providers) { provider in
                NavigationLink(destination: ProviderDetail(provider: provider)) {
                    ProviderRow(provider: provider)
                }
                .deleteDisabled(provider == providerDefaults.first!.defaultProvider || providers.count == 1)
            }
            .onDelete(perform: deleteProviders)
        }
        .navigationTitle("Providers")
        .toolbarTitleDisplayMode(.inline)
    }
    
    private var addButton: some View {
        Menu {
            ForEach(ProviderType.groups, id: \.rawValue) { group in
                if group == .local {
                    #if os(macOS)
                    ProviderSection(group: group)
                    #endif
                } else {
                    ProviderSection(group: group)
                }
            }
        } label: {
            Label("Create Provider", systemImage: "plus")
        }
    }
    
    private func deleteProviders(offsets: IndexSet) {
        var providersToDelete = offsets
        
        let fetchDescriptor = FetchDescriptor<ChatConfig>()
        guard let allChatConfigs = try? modelContext.fetch(fetchDescriptor) else {
            print("Failed to fetch ChatConfigs")
            return
        }

        let defaultProvider = providerDefaults.first!.defaultProvider
        
        for index in offsets {
            let providerToDelete = providers[index]
            
            if providerToDelete == defaultProvider {
                providersToDelete.remove(index)
            } else {
                for chatConfig in allChatConfigs where chatConfig.provider == providerToDelete {
                    chatConfig.provider = defaultProvider
                    chatConfig.model = chatConfig.provider.chatModel
                }
            }
        }
        
        for index in providersToDelete {
            modelContext.delete(providers[index])
        }
    }
}

#Preview {
    ProviderList()
        .modelContainer(for: Provider.self, inMemory: true)
}
