//
//  CommonModifiers.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct CommonInputStyling: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .padding(4)
            #if os(macOS) || os(visionOS)
//            .background(.bar)
            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
            #else
            .background(.background)
            #endif
            .ignoresSafeArea()
            .padding(8)
    }
    
    #if os(macOS)
    private let verticalPadding: CGFloat = 16
    #else
    private let verticalPadding: CGFloat = 12
    #endif
}

#Preview {
    InputArea(chat: .mockChat)
        .modifier(CommonInputStyling())
}
