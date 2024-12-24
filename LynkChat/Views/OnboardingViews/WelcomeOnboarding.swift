//
//  WelcomeOnboarding.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct WelcomeOnboarding: View {
    @State private var isAppear = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "hand.wave.fill")
                .apply {
                    if #available(iOS 18.0, macOS 15.0, *) {
                        $0.symbolEffect(.wiggle, options: .repeating, value: isAppear)
                    } else {
                        $0.symbolEffect(.pulse, value: isAppear)
                    }
                }
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("Welcome to LynkChat")
                .font(.title)
                .bold()
            
            Text("Chat with multiple LLM models, generate images, and more")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
        }
        .task {
            isAppear.toggle()
        }
    }
}

#Preview {
    WelcomeOnboarding()
        .frame(width: 500, height: 500)
}
