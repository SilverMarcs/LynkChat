//
//  AssistantMessageAux.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct AssistantMessageAux: View {
    var group: MessageGroup
    
    var body: some View {
        #if os(macOS)
        if group.isSplitView {
            HStack(alignment: .top) {
                AssistantMessage(message: group.activeMessage, group: group)
                
                Divider()
                    
                AssistantMessage(message: group.secondaryMessages[group.secondaryMessageIndex],
                                        group: group, showMenu: false)
            }
        } else {
            AssistantMessage(message: group.activeMessage, group: group)
        }
        #else
        AssistantMessage(message: group.activeMessage, group: group)
        #endif
    }
}

#Preview {
    AssistantMessageAux(group: .mockAssistantGroup)
        .frame(width: 500, height: 300)
}
