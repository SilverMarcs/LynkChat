//
//  AppearanceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/9/24.
//

import SwiftUI
import SwiftData

struct AppearanceSettings: View {
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared

    var body: some View {
        Form {
            Section("Font Size") {
                HStack {
                    Button("Reset") {
                        config.resetFontSize()
                    }
                    
                    Slider(value: $config.fontSize, in: 8...25, step: 1) {
                        Text("")
                    } minimumValueLabel: {
                        Text("")
                            .monospacedDigit()
                    } maximumValueLabel: {
                        Text(String(config.fontSize))
                            .monospacedDigit()
                    }
                }
            }

            Section("Markdown") {
                Picker(selection: $config.markdownProvider) {
                    ForEach(MarkdownProvider.allCases) { provider in
                        Text(provider.name)
                            .tag(provider)
                    }
                } label: {
                    Text("Markdown Provider")
                    Text("Use webview for best performance")
                }
                #if os(macOS)
                .pickerStyle(.radioGroup)
                #endif
                
                if config.markdownProvider == .webview {
                    Picker(selection: $config.codeBlockTheme) {
                        ForEach(CodeBlockTheme.allCases, id: \.self) { theme in
                            Text(theme.name)
                                .tag(theme)
                        }
                    } label: {
                        Text("Code Block Theme")
                        Text("Change chat selection to take effect")
                    }
                    
                    MDView(content: String.onlyCodeBlock)
                        .id(config.codeBlockTheme)
                        .padding(.bottom, -11)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Appearance")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    AppearanceSettings()
}

