//
//  GenericOnboardingView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

import SwiftUI

struct GenericOnboardingView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    var useSFSymbol: Bool = true
    let iconColor: Color
    let title: String
    let content: () -> Content
    let footerText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Icon and Title
            VStack(spacing: 16) {
                Group {
                    if useSFSymbol {
                        Image(systemName: icon)
                            .font(.system(size: 80))
                    } else {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                    }
                }
                .foregroundStyle(iconColor)
                
                Text(title)
                    .font(.title)
                    .bold()
            }
            .padding(.bottom)
            .animation(.default, value: icon)
            .animation(.default, value: iconColor)
            .multilineTextAlignment(.center)
            
            // Content
            content()
                .scrollDisabled(true)
                .formStyle(.grouped)
                #if !os(macOS)
                .scrollContentBackground(colorScheme == .dark ? .visible : .hidden)
                .padding(-20)
                #endif
            
            Spacer()
            
            // Footer
            Text(footerText)
                .italic()
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .padding()
    }
}
