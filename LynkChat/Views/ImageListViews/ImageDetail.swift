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
                ForEach(session.imageGenerations.sorted(by: { $0.date < $1.date }), id: \.self.id) { generation in
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
            .safeAreaBar(edge: .bottom) {
                ImageInputView(session: session)
            }
            #if os(macOS)
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
            #endif
        }
    }
}


#Preview {
    ImageDetail(session: .mockImageSession)
}
