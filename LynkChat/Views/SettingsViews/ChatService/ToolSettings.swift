//
//  PluginSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 14/09/2024.
//

import SwiftUI

struct PluginSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        NavigationStack {
            Form {
                Section("General Plugins") {
                    ForEach(Tool.allCases, id: \.self) { tool in
                        #warning("IMPLEMENT THIS")
                        Text("IMPLEMENT THIS")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Tools")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    PluginSettings()
}
