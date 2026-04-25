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
    @AppStorage("didAcceptAIDataConsent") private var didAcceptAIDataConsent = false
    @Environment(GodMode.self) var godMode

    @Namespace private var skipButtonSpace

    @State private var currentPage = OnboardingPage.welcome
    @State private var navigationDirection = NavigationDirection.forward

    private var visiblePages: [OnboardingPage] {
        OnboardingPage.allCases.filter { page in
            if page == .plugins { return false }
            if !godMode.isActivated {
                return page != .apiKey && page != .imageGen
            }
            return true
        }
    }

    private var currentIndex: Int {
        visiblePages.firstIndex(of: currentPage) ?? 0
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                pageContent

                Spacer()

                navigationControls
            }

            if currentPage != .welcome && currentPage != .ready && currentPage != .dataPrivacy {
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
            case .dataPrivacy:
                DataPrivacyOnboarding()
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
                if currentIndex > 0 {
                    Button("Previous") {
                        navigationDirection = .backward
                        withAnimation {
                            currentPage = visiblePages[currentIndex - 1]
                        }
                    }
                }

                Spacer()

                Button(currentPage != .ready ? "Next" : "Get Started") {
                    if currentIndex < visiblePages.count - 1 {
                        navigationDirection = .forward
                        withAnimation {
                            currentPage = visiblePages[currentIndex + 1]
                        }
                    } else {
                        hasCompletedOnboarding = true
                    }
                }
                .keyboardShortcut(currentPage == .ready ? .defaultAction : nil)
                .disabled(currentPage == .dataPrivacy && !didAcceptAIDataConsent)
            }

            PageDots(current: currentIndex, total: visiblePages.count)
        }
    }
}

#Preview {
    OnboardingView()
}
