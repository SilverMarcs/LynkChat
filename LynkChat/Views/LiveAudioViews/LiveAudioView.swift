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
        
        var cfg = WebPage.Configuration()
        cfg.deviceSensorAuthorization = .init { permission, frame, origin in
              switch permission {
              case .mediaCapture(let type):
                  if type == .microphone {
                      return .grant
                  }

              default:
                  return .deny
              }
            return .deny
          }

          _page = State(initialValue: WebPage(configuration: cfg))
    }

    var body: some View {
        NavigationStack {
//            VStack {
                Button {
                    Task { await toggleMic() }
                } label: {
                    Image(systemName: currentSymbol)
                        .foregroundStyle(.white.opacity(0.9))
                        .font(.system(size: currentSize, weight: .medium))
                        .contentTransition(.symbolEffect(.replace.offUp, options: .speed(1.2)))
                        .symbolEffect(.pulse.byLayer,
                                    options: .repeating.speed(pulseSpeed),
                                    isActive: shouldPulse)
                        .symbolEffect(.bounce.up,
                                      options: .repeating.speed(1.5),
                                    isActive: isSpeaking)
//                        .symbolEffect(.variableColor.iterative,
//                                    options: .repeating.speed(0.8),
//                                    isActive: isStreaming && !isSpeaking)
//                        .scaleEffect(isSpeaking ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isSpeaking)
                        .padding(20)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.extraLarge)
                .buttonBorderShape(.circle)
//                
//                // Status text
//                Text(statusText)
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                    .contentTransition(.numericText())
//                    .animation(.easeInOut(duration: 0.2), value: statusText)
//            }
            .task {
                await loadPage(url)
            }
            .onDisappear {
                resetSession()
                page.reload()
            }
            .onChange(of: page.title) {
                applyStateFromTitle()
            }
            .overlay(alignment: .topLeading) {
                WebView(page)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
            }
            .navigationTitle("Live")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: resetSession) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
            }
        }
    }
    
    // MARK: - UI State
    
    private var currentSymbol: String {
        return "waveform"
        
        if isSpeaking {
            return "waveform"
        } else if isStreaming {
            return "waveform"
        } else if hasSession {
            return "waveform"
        } else {
            return "waveform"
        }
    }
    
    private var currentSize: CGFloat {
        return 110
        
        if isSpeaking {
            return 105
        } else if isStreaming {
            return 110
        } else if hasSession {
            return 95
        } else {
            return 90
        }
    }
    
    private var shouldPulse: Bool {
        return isStreaming
    }
    
    private var pulseSpeed: Double {
        if isSpeaking {
            return 2.0
        } else if isStreaming {
            return 1.5
        } else {
            return 1.0
        }
    }
    
    private var statusText: String {
        if isSpeaking {
            return "Speaking..."
        } else if isStreaming {
            return "Listening..."
        } else if hasSession {
            return "Ready"
        } else {
            return "Tap to start"
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
            withAnimation(.easeInOut(duration: 0.3)) {
                if let s = json["isStreaming"] as? Bool { isStreaming = s }
                if let sp = json["isSpeaking"] as? Bool { isSpeaking = sp }
                if let hs = json["hasSession"] as? Bool { hasSession = hs }
            }
        }
    }
}

#Preview {
    LiveAudioView()
}
