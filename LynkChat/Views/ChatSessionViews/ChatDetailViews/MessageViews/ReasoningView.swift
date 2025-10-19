//
//  ReasoningView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/02/2025.
//

import SwiftUI

struct ReasoningView: View {
     let reason: ReasoningDetail
     
     @State private var showArguments = false
     
     var displayContent: String {
         switch reason.type {
         case .text:
             return reason.text ?? "No reasoning text"
         case .summary:
             return reason.summary ?? "No reasoning summary"
         case .encrypted:
             return reason.data ?? "[REDACTED]"
         }
     }
     
     var body: some View {
         Button {
             showArguments.toggle()
         } label: {
             Label(
                "Reasoning",
                 systemImage: "circle.hexagonpath"
             )
             .fontWeight(.semibold)
             .foregroundStyle(reason.type == .encrypted ? .red : .orange)
         }
         .labelStyle(.titleAndIcon)
         .buttonStyle(.bordered)
         #if os(macOS)
         .controlSize(.large)
         #endif
         .buttonBorderShape(.roundedRectangle)
         .popover(isPresented: $showArguments) {
             ScrollView {
                 NativeMarkdownView(text: displayContent)
                     .textSelection(.enabled)
             }
             .presentationDragIndicator(.visible)
             .presentationDetents([.medium])
             .contentMargins(20, for: .scrollContent)
             #if os(macOS)
             .frame(width: 500, height: 500)
             #endif
         }
     }
}
