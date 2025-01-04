//
//  ChatInspector.swift
//  LynkChat
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI
import SwiftData

struct ChatInspector: View {
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
                        .popoverTip(GenerateTitleTip())
                }
            }
            
            Section("Model") {
                ModelPicker(selectedModel: $chat.config.model)
            }
            
            Section("Parameters") {
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
            
            if chat.config.model.supportsTool {
                Section("Plugins") {
                    LabeledContent("Enable") {
                        ToolsBarView(config: $chat.config)
                            .padding(.bottom, -7)
                            #if !os(macOS)
                            .padding(.top, -5)
                            #endif
                    }
                    .frame(height: 25)
                }
            }
            
            Section("System Prompt") {
                sysPrompt
            }
            
            Section {
                VStack {
                    exportButton
                    Divider()
                    deleteAllMessages
                }
            }
        }
        .formStyle(.grouped)
        #if os(macOS)
        .frame(width: 400, height: 680)
        .overlay(alignment: .topTrailing) {
            DismissButton()
                .padding(10)
        }
        #endif
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
        Button(role: .destructive) {
            if chat.isReplying { return }
            
            showingDeleteConfirmation.toggle()
        } label: {
            Text("Delete All Messages")
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .foregroundStyle(.red)
        #if os(macOS)
        .buttonStyle(ClickHighlightButton())
        #else
        .buttonStyle(.plain)
        #endif
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
            Text("Export Markdown")
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        #if os(macOS)
        .buttonStyle(ClickHighlightButton())
        #else
        .buttonStyle(.plain)
        #endif
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

#Preview {
    ChatInspector(chat: Chat())
}
