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
                Toggle("Enable Markdown", isOn: $config.isMarkdownEnabled)

                #if os(macOS)
                if config.isMarkdownEnabled {
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
                #endif
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

