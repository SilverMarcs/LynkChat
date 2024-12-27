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
                    Text("Omit https:// but include /v1/ from the URL.\nCorrect input example: api.openai.com/v1")
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
            }
        }
        
        if !isApiKeyDisabled {   
            SecretInputView(label: "API Key", secret: $provider.apiKey)
        }
    }
    
    var isHostDisabled: Bool {
        !ProviderType.usesCustomOpenAI.contains(provider.type) || provider.type == .customGoogle || provider.type == .customAnthropic
    }
    
    var isApiKeyDisabled: Bool {
        !ProviderType.customTypes.contains(provider.type)
    }
}

#Preview {
    RegularProviderHost(provider: .openAIProvider)
}
