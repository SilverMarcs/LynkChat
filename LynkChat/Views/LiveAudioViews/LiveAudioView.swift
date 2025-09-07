//
//  LiveAudioView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 07/09/2025.
//

import SwiftUI
import WebKit

struct LiveAudioView: View {
    @ObservedObject var config: AppConfig = .shared
    @State private var page: WebPage = WebPage()
    
    private var urlWithKey: URL? {
        guard let baseURL = Bundle.main.url(forResource: "liveaudio", withExtension: "html") else { return nil }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "key", value: config.geminiApiKey)]
        return components?.url
    }

    var body: some View {
        NavigationStack {
            if let url = urlWithKey {
                WebView(page)
                    .navigationTitle("Live")
                    .toolbarTitleDisplayMode(.inlineLarge)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: resetSession) {
                                Image(systemName: "square.and.pencil")
                            }
                        }
                    }
                    .task {
                        page.load(url)
                    }
            } else {
                Text("Failed to load live audio UI")
                    .foregroundStyle(.red)
            }
        }
    }
    
    private func resetSession() {
        Task {
            do {
                try await page.callJavaScript("window.resetLiveAudio && window.resetLiveAudio();")
            } catch {
                print("Failed to reset session: \(error)")
            }
        }
    }
}

#Preview {
    LiveAudioView()
}
