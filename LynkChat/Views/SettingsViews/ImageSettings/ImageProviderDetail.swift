//
//  ImageProviderDetail.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI

struct ImageProviderDetail: View {
    @Bindable var provider: ImageProvider
    @State var showModelAdder = false
    
    var body: some View {
        Form {
            header
            
            Section("Host") {
                TextField("Host URL", text: $provider.baseUrl)
                TextField("API Key", text: $provider.apiKey)
            }
            
            Section {
                List($provider.models, id: \.self) {$model in
                    #if os(macOS)
                    HStack {
                        TextField("Name", text: $model.name)
                        TextField("Code", text: $model.code)
                            .monospaced()
                    }
                    .padding(5)
                    .labelsHidden()
                    #else
                    VStack(alignment: .leading) {
                        TextField("Name", text: $model.name)
                        TextField("Code", text: $model.code)
                            .monospaced()
                    }
                    #endif
                }
                .sheet(isPresented: $showModelAdder) {
                    ModelAdder() { name, code in
                        provider.models.append(.init(code: code, name: name))
                    }
                }
            } header: {
                HStack {
                    Text("Models")
                    
                    Spacer()
                    
                    Button(action: { showModelAdder.toggle() }) {
                        Label("Add", systemImage: "plus")
                    }
                    #if os(macOS)
                    .labelStyle(.titleOnly)
                    #else
                    .labelStyle(.iconOnly)
                    #endif
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.visible)
    }
    
    private var header: some View {
        HStack {
            ProviderImage(provider: provider, frame: 33, scale: .large)
            
            Group {
            #if os(macOS)
                TextEditor(text: $provider.name)
            #else
                TextField("Name", text: $provider.name)
            #endif
            }
                .textEditorStyle(.plain)
            #if os(macOS)
                .font(.title)
            #else
                .font(.title2)
            #endif
                .padding(5)
                .onChange(of: provider.name) {
                    provider.name = String(provider.name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(18))
                }
            
            Spacer()
        }
    }
}
