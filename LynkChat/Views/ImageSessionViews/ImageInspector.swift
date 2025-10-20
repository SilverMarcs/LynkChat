//
//  ImageInspector.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageInspector: View {
    @Bindable var session: ImageSession
    
    @Binding var showingInspector: Bool
    
    var body: some View {
        Form {
            Section("Title") {
                TextField("Title", text: $session.title)
                    .labelsHidden()
            }
            
            Section {
                Picker("Mode", selection: $session.config.mode) {
                    ForEach(GenerationMode.allCases) { mode in
                        Label(mode.rawValue, systemImage: mode.imageName)
                            .tag(mode)
                    }
                }
            }
            
            Section("Models") {
                ImageModelPickers(config: $session.config)
            }
            .labelStyle(.titleAndIcon)
            
            Section("Parameters") {
                Picker("Number of Images", selection: $session.config.numImages) {
                    ForEach(1 ... 4, id: \.self) { num in
                        Text(String(num)).tag(num)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem {
                Spacer()
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingInspector.toggle()
                } label: {
                    Label("Toggle Inspector", systemImage: "sidebar.right")
                }
            }
        }

    }
}

#Preview {
    ImageInspector(session: .mockImageSession, showingInspector: .constant(true))
}
