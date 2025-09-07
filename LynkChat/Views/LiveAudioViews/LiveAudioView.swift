//
//  LiveAudioView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 07/09/2025.
//  Zabir Raihan
//

import SwiftUI
import WebKit

struct LiveAudioView: View {
    @ObservedObject var config: AppConfig = .shared
    @State private var page: WebPage = WebPage()

    @State private var isStreaming = false
    @State private var isSpeaking = false
    @State private var hasSession = false

    private let url: URL

    init() {
        guard let baseURL = Bundle.main.url(forResource: "liveaudio", withExtension: "html") else {
            fatalError("Could not find liveaudio.html in bundle")
        }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "key", value: AppConfig.shared.geminiApiKey)]
        self.url = components.url!
    }

    var body: some View {
        NavigationStack {
            Button {
                Task { await toggleMic() }
            } label: {
                Image(systemName: isStreaming ? "pause.fill" : "play.fill")
                    .contentTransition(.symbolEffect(.replace, options: .speed(1.5)))
                    .font(.system(size: 100))
                    .padding(20)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            .buttonBorderShape(.circle)
            .task {
                await loadPage(url)
            }
            .onChange(of: page.title) {
                applyStateFromTitle()
            }
            .overlay {
                WebView(page)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
            }
            .navigationTitle("Live")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: resetSession) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
            }
        }
    }

    // MARK: - JS bridge

    private func loadPage(_ url: URL) async {
        page.load(url)
        _ = try? await page.callJavaScript("window.liveAudio?.syncStateToTitle?.()")
    }

    private func toggleMic() async {
        _ = try? await page.callJavaScript("window.liveAudio?.toggle?.()")
    }

    private func resetSession() {
        Task {
            do {
                try await page.callJavaScript("window.liveAudio?.reset?.()")
            } catch {
                print("Failed to reset session: \(error)")
            }
        }
    }

    private func applyStateFromTitle() {
        let title = page.title
        guard let data = title.data(using: .utf8) else { return }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let s = json["isStreaming"] as? Bool { isStreaming = s }
            if let sp = json["isSpeaking"] as? Bool { isSpeaking = sp }
            if let hs = json["hasSession"] as? Bool { hasSession = hs }
        }
    }
}

#Preview {
    LiveAudioView()
}
