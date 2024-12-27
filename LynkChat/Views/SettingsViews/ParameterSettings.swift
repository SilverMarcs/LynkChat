//
//  ParameterSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

struct ParameterSettings: View {
    @ObservedObject var config = ChatConfigDefaults.shared
    @State var expandAdvanced: Bool = true

    var body: some View {
        Form {
            Section("Basic") {
                Toggle(isOn: $config.stream) {
                    Text("Stream")
                }
                
                Slider(
                    value: Binding(
                        get: { Double(config.temperature) },
                        set: { config.temperature = Double($0) }
                    ),
                    in: 0...2,
                    step: 0.1,
                    label: { Text("Temperature") },
                    minimumValueLabel: {
                        Text("")
                            .frame(width: 0)
                    },
                    maximumValueLabel: {
                        Text(String(format: "%.1f", config.temperature))
                        #if os(macOS)
                            .frame(width: 17)
                        #else
                            .frame(width: 25)
                        #endif
                    }
                )
                
               Picker("Max Tokens", selection: $config.maxTokens) {
                    ForEach(MaxTokens.allCases, id: \.self) { option in
                        Text(option.description)
                            .tag(option)
                    }
                }
            }

            Section("System Prompt") {
                sysPrompt
            }
        }
        .navigationTitle("Parameters")
        .toolbarTitleDisplayMode(.inline)
        .formStyle(.grouped)
    }
    
    var sysPrompt: some View {
        TextField("System Prompt", text: $config.systemPrompt, axis: .vertical)
            .lineLimit(lineLimit, reservesSpace: true)
            .labelsHidden()
    }
    
    var lineLimit: Int {
        #if os(macOS)
        8
        #else
        5
        #endif
    }
}

#Preview {
    ParameterSettings()
}
