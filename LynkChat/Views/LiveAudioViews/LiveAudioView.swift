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
    
    private var urlWithKey: URL? {
        guard let baseURL = Bundle.main.url(forResource: "liveaudio", withExtension: "html") else { return nil }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "key", value: config.geminiApiKey)]
        return components?.url
    }
    
    @State var page: WebPage = WebPage()

    var body: some View {
        NavigationStack {
            if let url = urlWithKey {
                WebView(url: url)
                    .navigationTitle("Live")
                    .toolbarTitleDisplayMode(.inlineLarge)
            } else {
                Text("Failed to load live audio UI")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    LiveAudioView()
}
