//
//  ChatToolbar.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ChatToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Bindable var chat: Chat
    
    @State private var showingInspector: Bool = false
    @State private var showingSecondaryModels = false

    var body: some ToolbarContent {        
        ToolbarSpacer(.fixed)
        
        ToolbarItem(placement: .navigation) {
            Button {
                showingInspector.toggle()
            } label: {
                Label("Inspector", systemImage: "slider.vertical.3")
            }
            .keyboardShortcut(".")
            .sheet(isPresented: $showingInspector) {
                ChatInspector(chat: chat)
            }
        }
    
        ToolbarSpacer(.fixed)
        
        ToolbarItem(placement: .primaryAction) {
            Picker(selection: $chat.config.thinkingBudget) {
                ForEach(ThinkingBudget.allCases, id: \.self) { budget in
                    Label(budget.displayName, systemImage: budget.systemImage)
                        .tag(budget)
                }
            } label: {
                Label("Thinking Budget", systemImage: "timer")
            }
            .labelsHidden()
            .pickerStyle(.segmented)
        }
        
        ToolbarSpacer(.fixed)
        
        ToolbarItem(placement: .primaryAction) {
            ModelPicker(selectedModel: $chat.config.model)
        }
        
        if chat.config.models.count > 1 {
            ToolbarItem {
                Button("+\(chat.config.models.count - 1)") {}
            }
        }
        
        if chat.status == .temporary {
            ToolbarSpacer(.fixed)
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    chat.status = .normal
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .popoverTip(TemporaryChatTip())
            }
        }
    }
}

extension ToolbarItemPlacement {
    static let searchPanel = accessoryBar(id: "com.SilverMarcs.LynkChat.searchPanel")
}
    
