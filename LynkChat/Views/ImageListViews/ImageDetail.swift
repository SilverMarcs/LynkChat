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
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
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
                AppConfig.shared.proxy = proxy
                Scroller.scrollToBottom(animated: false)
            }
            #if os(macOS)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ImageInputView(session: session)
            }
            .navigationTitle(session.title)
            #else
            .toolbar(.hidden, for: .tabBar)
            .searchable(text: $session.prompt, prompt: "Generate Images")
//            .onSubmit(of: .search) {
//                Task {
//                    await session.send()
//                }
//            }
            .onReceive(NotificationCenter.default.publisher(for: UISearchTextField.textDidEndEditingNotification)) { notification in
                Task {
                    await session.send()
                }
            }
            .toolbar {
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
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)) { _ in
                Scroller.scrollToBottom()
            }
            .sheet(isPresented: $showingInspector) {
                ImageInspector(session: session, showingInspector: $showingInspector)
                    .presentationDetents(horizontalSizeClass == .compact ? [.medium] : [.large])
            }
            #endif
        }
    }
}


#Preview {
    ImageDetail(session: .mockImageSession)
}
