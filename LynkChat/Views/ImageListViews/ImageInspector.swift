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
            
            Section("Models") {
                Picker("Creation Model", selection: $session.config.model) {
                    ForEach(ImageModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
                .labelStyle(.titleAndIcon)
                
                Picker("Editing Model", selection: $session.config.editingModel) {
                    ForEach(ImageEditingModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
                .labelStyle(.titleAndIcon)

            }

            Section("Maintenance") {
                Button(role: .destructive) {
                    session.deleteFailedGenerations()
                } label: {
                    Label("Delete Failed Generations", systemImage: "trash")
                        .contentShape(.rect)
                        #if !os(macOS)
                        .labelStyle(.titleOnly)
                        #endif
                }
                .tint(.red)
                .buttonStyle(.plain)
                .disabled(session.imageGenerations.allSatisfy { !$0.isFailed })
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
