//
//  ImageDetailCommon.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI

struct ImageDetailCommon: View {
    var session: ImageSession
    var proxy: ScrollViewProxy
    
    var body: some View {
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
            Scroller.scrollToBottom(animated: true, delay: 0.1)
        }
        .safeAreaBar(edge: .bottom) {
            ImageInputView(session: session)
        }
    }
}
