//
//  SecondaryNavigationButtons.swift
//  LynkChat
//
//  Created by Zabir Raihan on 01/12/2024.
//

import SwiftUI

struct SecondaryNavigationButtons: View {
    var group: MessageGroup
    
    var body: some View {
        if group.secondaryMessages.count > 1 {
            ControlGroup {
                Button {
                    group.previousSecondaryMessage()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .disabled(!group.canGoToPreviousSecondary)
                
                Button {
                    group.nextSecondaryMessage()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .disabled(!group.canGoToNextSecondary)
            }
            .controlGroupStyle(.navigation)
        }
    }
}
