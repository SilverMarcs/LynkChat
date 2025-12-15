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
    @AppStorage("geminiApiKey") var geminiApiKey: String = ""
    @State private var page: WebPage = WebPage()

    @State private var isStreaming = false
    @State private var isPaused = false
    @State private var isSpeaking = false
    @State private var hasSession = false

    init() {
        guard Bundle.main.url(forResource: "liveaudio", withExtension: "html") != nil else {
            fatalError("Could not find liveaudio.html in bundle")
        }
        
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
            Button {
                Task { await toggleMic() }
            } label: {
                Image(systemName: currentSymbol)
//                    .foregroundStyle(.white.opacity(0.9))
                    .font(.system(size: currentSize, weight: .medium))
                    .contentTransition(.symbolEffect(.replace, options: .speed(1.2)))
//                    .symbolEffect(.pulse.byLayer,
//                                options: .repeating.speed(pulseSpeed),
//                                isActive: shouldPulse)
                    .symbolEffect(.bounce.byLayer, // try bounce up
                                  options: .repeating.speed(1.5),
                                isActive: isSpeaking)
//                    .symbolEffect(.breathe,
//                                  options: .repeating.speed(1.5),
//                                isActive: isSpeaking)
                    .symbolEffect(.variableColor.iterative,
//                    .symbolEffect(.pulse.byLayer,
                                  options: .repeating.speed(1),
                                isActive: (isStreaming || isSpeaking) && !isPaused)
//                    .symbolEffect(.variableColor.iterative,
//                                options: .repeating.speed(0.8),
//                                isActive: isSpeaking && !isPaused)
//                    .animation(.easeInOut(duration: 0.3), value: isSpeaking)
                    .padding(20)
            }
//            .disabled(!hasSession)
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            .buttonBorderShape(.circle)
            .task {
                guard let baseURL = Bundle.main.url(forResource: "liveaudio", withExtension: "html") else {
                    return
                }
                var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
                components.queryItems = [URLQueryItem(name: "key", value: geminiApiKey)]
                if let url = components.url {
                    await loadPage(url)
                }
                try? await Task.sleep(for: .seconds(0.5))
                await toggleMic()
            }
            .onDisappear {
                Task {
                    await resetSession()
                    page.reload()
                }
            }
            .onChange(of: page.title) {
                applyStateFromTitle()
            }
            .overlay(alignment: .topLeading) {
                // This wont trigger permission overlay unless size is big enough TODO: fix
                WebView(page)
                    .frame(width: 10, height: 10)
                    .opacity(0.01)
            }
            .navigationTitle("Live")
            .navigationSubtitle(statusText)
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await resetSession() }
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            #if os(macOS)
            .padding(.top, -20)
            #endif
        }
    }
    
    // MARK: - UI State
    
    private var currentSymbol: String {
        if isSpeaking {
            return "waveform"
        } else if isStreaming {
            return "waveform"
        } else if isPaused {
            return "waveform.mid"
        } else if hasSession {
            return "waveform"
        } else {
            return "waveform.mid"
        }
    }
    
    private var currentSize: CGFloat {
        return 110
    }
    
    private var shouldPulse: Bool {
        return (isStreaming || isSpeaking) && !isPaused
    }
    
    private var pulseSpeed: Double {
        if isSpeaking {
            return 1.25
        } else if isStreaming {
            return 1.25
        } else if isPaused {
            return 0
        } else {
            return 1.25
        }
    }
    
    private var statusText: String {
        if isSpeaking {
            return "Speaking..."
        } else if isStreaming {
            return "Listening..."
        } else if isPaused {
            return "Paused"
        } else if hasSession {
            return "Ready"
        } else {
            return "Connecting..."
        }
    }

    // MARK: - JS bridge

    private func loadPage(_ url: URL) async {
        page.load(url)
        _ = try? await page.callJavaScript("window.liveAudio?.syncStateToTitle?.()")
        _ = try? await page.callJavaScript("window.liveAudio?.establishConnection?.()")
    }

    private func toggleMic() async {
        _ = try? await page.callJavaScript("window.liveAudio?.toggle?.()")
    }

    private func resetSession() async {
        let _ = try? await page.callJavaScript("window.liveAudio?.reset?.()")
    }

    private func applyStateFromTitle() {
        let title = page.title
        guard let data = title.data(using: .utf8) else { return }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            withAnimation(.easeInOut) {
                if let s = json["isStreaming"] as? Bool { isStreaming = s }
                if let p = json["isPaused"] as? Bool { isPaused = p }
                if let sp = json["isSpeaking"] as? Bool { isSpeaking = sp }
                if let hs = json["hasSession"] as? Bool { hasSession = hs }
            }
        }
    }
}

#Preview {
    LiveAudioView()
}
