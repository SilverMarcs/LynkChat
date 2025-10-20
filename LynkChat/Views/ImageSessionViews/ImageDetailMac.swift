//
//  ImageDetailMac.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/10/2025.
//

import SwiftUI

struct ImageDetailMac: View {
    var session: ImageSession
    
    var body: some View {
        ScrollViewReader { proxy in
            ImageDetailCommon(session: session, proxy: proxy)
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
        }
    }
}
