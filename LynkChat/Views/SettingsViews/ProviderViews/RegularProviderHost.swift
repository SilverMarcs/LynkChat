//
//  RegularProviderHost.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/12/2024.
//

import SwiftUI

struct RegularProviderHost: View {
    @Bindable var provider: Provider
    
    @State private var showPopover = false
    
    var body: some View {
        HStack {
            if isHostDisabled {
                LabeledContent("Host URL") {
                    Text(provider.baseUrl)
                }
            } else {
                TextField("Host URL", text: $provider.baseUrl)
            }
            
            if !isHostDisabled {
                Button {
                    showPopover.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showPopover) {
                    Text("Omit https:// and /v1/ from the URL.\nCorrect input example: api.openai.com")
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
            }
        }
        
        if !isHostDisabled {   
            SecretInputView(label: provider.type == .github ? "Personal Access Token" : "API Key", secret: $provider.apiKey)
        }
    }
    
    var isHostDisabled: Bool {
        !ProviderType.customTypes.contains(provider.type)
    }    
}

#Preview {
    RegularProviderHost(provider: .openAIProvider)
}
