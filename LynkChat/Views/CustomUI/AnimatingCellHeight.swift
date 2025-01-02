//
//  AnimatingCellHeight.swift
//  LynkChat
//
//  Created by Zabir Raihan on 02/01/2025.
//

import SwiftUI

struct AnimatingCellHeight: AnimatableModifier {
    var height: CGFloat = 0

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        content.frame(height: height)
    }
}
