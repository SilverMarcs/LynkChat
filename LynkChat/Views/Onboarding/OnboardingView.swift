//
//  OnboardingView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/11/2024.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    @Namespace private var skipButtonSpace
    
    @State private var currentPage = OnboardingPage.welcome
    @State private var navigationDirection = NavigationDirection.forward
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                pageContent
                
                Spacer()
                
                navigationControls
            }
            
            if currentPage != .welcome && currentPage != .ready {
                Button("Skip") {
                    hasCompletedOnboarding = true
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .matchedGeometryEffect(id: "skipButton", in: skipButtonSpace)
            }
        }
        .presentationBackground(.background)
        .padding()
        .interactiveDismissDisabled(!hasCompletedOnboarding)
        #if os(macOS)
        .frame(width: 500, height: 500)
        #endif
    }
    
    @ViewBuilder
    private var pageContent: some View {
        Group {
            switch currentPage {
            case .welcome:
                WelcomeOnboarding()
            case .apiKey:
                ModelOnboarding()
            case .plugins:
                PluginsOnboarding()
            #if os(macOS)
            case .quickPanel:
                QuickPanelOnboarding()
            #else
            case .permissions:
                PermissionsOnboarding()
            #endif
            case .imageGen:
                ImageGenOnboarding()
            case .ready:
                ReadyPageView()
            }
        }
        .transition(.asymmetric(
            insertion: navigationDirection == .forward ?
                .move(edge: .trailing) : .move(edge: .leading),
            removal: navigationDirection == .forward ?
                .move(edge: .leading) : .move(edge: .trailing)
        ))
    }
    
    private var navigationControls: some View {
        ZStack {
            HStack(spacing: 20) {
                if currentPage != .welcome {
                    Button("Previous") {
                        navigationDirection = .backward
                        withAnimation {
                            currentPage = OnboardingPage(rawValue: currentPage.rawValue - 1) ?? .welcome
                        }
                    }
                }
                
                if currentPage == .welcome {
                    Button("Skip") {
                        hasCompletedOnboarding = true
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .matchedGeometryEffect(id: "skipButton", in: skipButtonSpace)
                }
                
                Spacer()
                
                Button(currentPage != .ready ? "Next" : "Get Started") {
                    if currentPage != .ready {
                        navigationDirection = .forward
                        withAnimation {
                            currentPage = OnboardingPage(rawValue: currentPage.rawValue + 1) ?? .ready
                        }
                    } else {
                        hasCompletedOnboarding = true
                    }
                }
                .keyboardShortcut(currentPage == .ready ? .defaultAction : nil)
            }
            
            PageDots(current: currentPage.rawValue, total: OnboardingPage.allCases.count)
        }
    }
}

#Preview {
    OnboardingView()
}
