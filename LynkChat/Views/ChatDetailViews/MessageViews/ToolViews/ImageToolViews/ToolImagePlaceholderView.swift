//
//  ToolImagePlaceholderView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolImagePlaceholderView: View {
    var body: some View {
        ProgressView()
            .frame(width: 300, height: 300)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.background.quinary)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ToolImagePlaceholderView()
}
