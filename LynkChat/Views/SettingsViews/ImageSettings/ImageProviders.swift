//
//  ImageProviders.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI
import SwiftData

struct ImageProviders: View {
    @Query var providers: [ImageProvider]
    
    var body: some View {
        List {
            ForEach(providers) { provider in
                NavigationLink {
                    ImageProviderDetail(provider: provider)
                } label: {
                    HStack {
                        ProviderImage(provider: provider, radius: 7, frame: 22, scale: .medium)
                        Text(provider.name)
                        Spacer()
                        #if os(macOS)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                        #endif
                    }
                    #if os(macOS)
                    .padding(5)
                    #endif
                }
            }
        }
    }
}

#Preview {
    ImageProviders()
}
