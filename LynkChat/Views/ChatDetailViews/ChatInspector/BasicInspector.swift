//
//  BasicInspector.swift
//  LynkChat
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI
import SwiftData

struct BasicInspector: View {
    @Environment(\.dismiss) var dismiss
    
    @Bindable var chat: Chat
    
    @State var isGeneratingTtile: Bool = false
    @State var showingDeleteConfirmation: Bool = false
    @State private var isExportingJSON = false
    @State private var isExportingMarkdown = false

    var body: some View {
        Form {
            Section("Title") {
                HStack(spacing: 0) {
                    title
                    Spacer()
                    generateTitle
                }
            }
            
            Section("Model") {
                ModelPicker(selectedModel: $chat.config.model)
            }
            
            Section("Parameters") {
                Toggle(isOn: $chat.config.stream) {
                    Text("Stream")
                }
                
                Picker("Max Tokens", selection: $chat.config.maxTokens) {
                    ForEach(MaxTokens.allCases, id: \.self) { option in
                        Text(option.description).tag(option)
                    }
                }
                
                
                Slider(
                    value: Binding(
                        get: { Double(chat.config.temperature) },
                        set: { chat.config.temperature = Double($0) }
                    ),
                    in: 0...2,
                    step: 0.1,
                    label: { Text("Temperature") },
                    minimumValueLabel: {
                        Text("")
                            .frame(width: 0)
                    },
                    maximumValueLabel: {
                        Text(String(format: "%.1f", chat.config.temperature))
                        #if os(macOS)
                            .frame(width: 17)
                        #else
                            .frame(width: 25)
                        #endif
                    }
                )
            }
            
            Section("System Prompt") {
                sysPrompt
            }
            
            Section {
                exportButton
                deleteAllMessages
            }
        }
        .formStyle(.grouped)
    }
    
    private var title: some View {
        TextField("Title", text: $chat.title)
            .lineLimit(1)
            .labelsHidden()
    }
    
    private var sysPrompt: some View {
        TextField("System Prompt", text: $chat.config.systemPrompt, axis: .vertical)
            #if os(macOS)
            .lineLimit(6, reservesSpace: true)
            #else
            .lineLimit(5, reservesSpace: true)
            #endif
            .labelsHidden()
    }
    
    private var generateTitle: some View {
        Button {
            if chat.isReplying { return }
            isGeneratingTtile.toggle()
            Task {
                await chat.generateTitle(forced: true)
                isGeneratingTtile.toggle()
            }
        } label: {
            Image(systemName: "sparkles")
                .symbolEffect(.pulse, isActive: isGeneratingTtile)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.mint.gradient)
    }
    
    private var deleteAllMessages: some View {
        Button(action: {}) {
            Button(role: .destructive) {
                if chat.isReplying { return }
                
                showingDeleteConfirmation.toggle()
            } label: {
                Text("Delete All Messages")
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.red)
            #if os(macOS)
            .buttonStyle(ClickHighlightButton())
            #else
            .buttonStyle(.bordered)
            #endif
        }
        .buttonStyle(.plain)
        .listRowBackground(EmptyView())
        .listRowInsets(EdgeInsets())
        .confirmationDialog("Are you sure you want to delete all messages?", isPresented: $showingDeleteConfirmation) {
            Button("Delete All", role: .destructive) {
                chat.deleteAllMessages()
                dismiss()
            }
            
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private var exportButton: some View {
        Button {
            isExportingMarkdown = true
        } label: {
            Label("Export Markdown", systemImage: "richtext.page")
                .labelStyle(.titleOnly)
        }
        .buttonStyle(ClickHighlightButton())
        .foregroundStyle(.accent)
        .fileExporter(
            isPresented: $isExportingMarkdown,
            document: MarkdownBackup(chat: chat),
            contentType: .plainText,
            defaultFilename: "\(chat.title).md"
        ) { result in
            switch result {
            case .success(let url):
                print("Markdown saved to \(url)")
            case .failure(let error):
                print("Error saving markdown: \(error)")
            }
        }
    }
}
