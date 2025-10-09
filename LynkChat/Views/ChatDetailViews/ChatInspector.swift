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
//                        .popoverTip(GenerateTitleTip())
                }
            }
            
            Section("Model") {
                #if os(macOS)
                LabeledContent {
                    ModelMenuPicker(selectedModels: $chat.config.models)
                } label: {
                    Text("Models")
                }
                #else
                ModelSinglePicker(selectedModel: $chat.config.model)
                #endif
            }
            
            Section("Parameters") {
                Picker(selection: $chat.config.thinkingBudget) {
                    ForEach(ThinkingBudget.allCases, id: \.self) { budget in
                        Label(budget.displayName, systemImage: budget.systemImage)
                            .labelStyle(.titleOnly)
                            .tag(budget)
                    }
                } label: {
                    Label("Thinking Budget", systemImage: "timer")
                }
                
                Picker(selection: $chat.config.temperature) {
                    ForEach(Temperature.allCases, id: \.self) { option in
                        Text(option.name).tag(option)
                    }
                } label: {
                    Label("Behaviour", systemImage: "brain")
                }
            }
//            
//            Section("Plugins") {
//                ToolsToggleView(config: $chat.config)
//            }
            
            Section("System Prompt") {
                sysPrompt
            }
            
            Section {
                exportButton
            }
        }
        .formStyle(.grouped)
        .presentationDragIndicator(.visible)
        #if os(macOS)
        .overlay(alignment: .topTrailing) {
            HStack {
                Spacer()
                
                Text("Tokens: \(unsafe String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))")
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Button(role: .close) {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .controlSize(.large)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
            }
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
    
    
    private var exportButton: some View {
        Button {
            isExportingMarkdown = true
        } label: {
            Text("Export Markdown")
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.accent)
        .buttonStyle(.borderless)
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
