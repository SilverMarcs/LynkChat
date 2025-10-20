//
//  ImageDetailMobile.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/10/2025.
//

import SwiftUI

struct ImageDetailMobile: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Bindable var session: ImageSession
    @State private var showingInspector: Bool = false
    @State private var isFocused: Bool = false
    @Namespace private var transition
    
    var body: some View {
        ScrollViewReader { proxy in
            ImageDetail(session: session, proxy: proxy)
                .navigationTitle("Models")
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
                .searchable(text: $session.prompt, isPresented: $isFocused, prompt: "Generate Images")
                .onSubmit(of: .search) {
                    isFocused = false
                    
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
                        ImageSessionInputMenu(session: session)
                    }
                    
                    ToolbarSpacer(.fixed, placement: .bottomBar)
                    
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)

                    ToolbarSpacer(.fixed, placement: .bottomBar)
                }
                .listStyle(.plain)
                .navigationTitle(session.title)
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
        }
    }
}
