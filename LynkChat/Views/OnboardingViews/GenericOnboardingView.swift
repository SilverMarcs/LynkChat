//
//  GenericOnboardingView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

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
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                // Icon and Title
                VStack(spacing: 10) {
                    Group {
                        if useSFSymbol {
                            Image(systemName: icon)
                        } else {
                            Image(icon)
                        }
                    }
                    .foregroundStyle(iconColor)
                    .font(.system(size: geometry.size.height * 0.1))
                    
                    Text(title)
                        .font(.title)
                        .bold()
                }
                .frame(height: geometry.size.height * 0.25)
                .animation(.default, value: icon)
                .animation(.default, value: iconColor)
                
                // Content
                content()
                    .scrollDisabled(true)
                    .formStyle(.grouped)
                    #if os(iOS)
                    .scrollContentBackground(colorScheme == .dark ? .visible : .hidden)
                    #endif
                    .frame(height: geometry.size.height * 0.4)
                
                Spacer()
                
                // Footer
                Text(footerText)
                    .italic()
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
        }
    }
}
