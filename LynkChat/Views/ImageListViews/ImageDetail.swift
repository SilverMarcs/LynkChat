//
//  ImageDetail.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageDetail: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Bindable var session: ImageSession
    @State private var showingInspector: Bool = false
    @State private var isFocused: Bool = false
    @Namespace private var transition
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                // Show uploaded images section
                UploadedImagesView(session: session)
                
                ForEach(session.imageGenerations.sorted(by: { $0.date < $1.date })) { generation in
                    GenerationView(generation: generation)
                        .padding(.bottom)
                }
                .listRowSeparator(.hidden)
                
                Color.clear
                    .id(String.bottomID)
                    .listRowSeparator(.hidden)
            }
            .task {
                AppSettings.shared.proxy = proxy
                Scroller.scrollToBottom(animated: false)
            }
            #if os(macOS)
            .safeAreaBar(edge: .bottom) {
                ImageInputView(session: session)
            }
            .navigationTitle(session.title)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Delete Last Message", role: .destructive) {
                        if let last = session.imageGenerations.last {
                            session.deleteGeneration(last)
                        }
                    }
                    .keyboardShortcut(.delete)
                }
            }
            #else
            .toolbarTitleMenu {
                Picker("Model", selection: $session.config.model) {
                    ForEach(ImageModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
                .labelStyle(.titleAndIcon)
            }
            .toolbar(.hidden, for: .tabBar)
            .searchable(text: $session.prompt, isPresented: $isFocused, prompt: "Generate Images")
            .onSubmit(of: .search) {
                Task {
                    await session.send()
                }
            }
            .onChange(of: isFocused) {
                if isFocused {
                    Scroller.scrollToBottom(delay: 0.2)
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        Task {
                            // Get the most recent generation's prompt (if any) and regenerate
                            if let latest = session.imageGenerations.sorted(by: { $0.date < $1.date }).last {
                                // copy prompt from the generation's config to session prompt
                                await session.send(latest.config.prompt)
                            }
                        }
                    } label: {
                        Label("Regenerate", systemImage: "arrow.clockwise")
                    }
                    .disabled(session.imageGenerations.isEmpty)
                }
                
                ToolbarSpacer(.fixed, placement: .bottomBar)
                
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
            }
            .listStyle(.plain)
            .navigationTitle(session.config.model.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        showingInspector.toggle()
                    } label: {
                        Label("Show Inspector", systemImage: "info")
                    }
                }
                .matchedTransitionSource(id: "image-inspector-button", in: transition)
            }
            .sheet(isPresented: $showingInspector) {
                ImageInspector(session: session, showingInspector: $showingInspector)
                    .navigationTransition(.zoom(sourceID: "image-inspector-button", in: transition))
                    .presentationDetents(horizontalSizeClass == .compact ? [.medium] : [.large])
            }
            #endif
        }
    }
}


#Preview {
    ImageDetail(session: .mockImageSession)
}
