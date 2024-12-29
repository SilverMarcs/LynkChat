//
//  View+Scene++.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import SwiftUI

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

#if os(macOS)
extension Scene {
    func disableWindowRestoration() -> some Scene {
        if #available(macOS 15, *) {
            return self.restorationBehavior(.disabled)
        } else {
            return self
        }
    }
}
#endif
