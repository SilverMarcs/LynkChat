//
//  ImageDetailMobile.swift
//  LynkChat
//
//  Created by Codex on 30/10/2025.
//

import SwiftUI

struct ImageDetail: View {
    @Bindable var session: ImageSession

    @Namespace private var transition

    @State private var isFocused: Bool = false
    @State private var showingInspector: Bool = false

    // Gallery handled inside ImageGridView

    var body: some View {
        ImageGridView(generations: session.imageGenerations)
        .safeAreaBar(edge: .bottom) {
            ImageInputView(session: session)
        }
        .toolbarTitleMenu {
            Picker("Model", selection: $session.config.model) {
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
        .toolbar(.hidden, for: .tabBar)
        .searchable(text: $session.config.prompt, isPresented: $isFocused, prompt: "Generate Images")
        .onSubmit(of: .search) {
            isFocused = false
            Task { await session.send() }
        }
        .onChange(of: isFocused) {
            if isFocused { Scroller.scrollToBottom(delay: 0.2) }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                ImageSessionInputMenu(session: session)
            }

            ToolbarSpacer(.fixed, placement: .bottomBar)

            DefaultToolbarItem(kind: .search, placement: .bottomBar)

            ToolbarSpacer(.fixed, placement: .bottomBar)

            ToolbarItem(placement: .primaryAction) {
                Button { showingInspector.toggle() } label: {
                    Label("Show Inspector", systemImage: "info")
                }
            }
            .matchedTransitionSource(id: "image-inspector-button", in: transition)
        }
        .navigationTitle(session.title)
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingInspector) {
            ImageInspector(session: session, showingInspector: $showingInspector)
                .navigationTransition(.zoom(sourceID: "image-inspector-button", in: transition))
                .presentationDetents([.medium, .large])
        }
        // Fullscreen gallery presented inside ImageGridView
    }
}
