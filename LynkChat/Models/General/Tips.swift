//
//  Tips.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/11/2024.
//

import TipKit

struct PlusButtonTip: Tip {
    var title: Text {
        Text("⌘ + Enter to send, ⌘ + L to focus on input box, ⌘ + V to paste files")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

struct SwipeActionTip: Tip {
    var title: Text {
        Text("Swipe Actions")
    }
    
    var message: Text? {
        Text("Swipe left or right on list row for more actions")
    }
    
    var image: Image? {
        Image(systemName: "hand.draw.fill")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

struct GenerateTitleTip: Tip {
    var title: Text {
        Text("Generate Title")
    }
    
    var message: Text? {
        Text("Click on \(Image(systemName: "sparkles")) to generate a title based on conversation. Configure auto title generation in settings")
    }
    
    var image: Image? {
        Image(systemName: "sparkles")
    }
}

struct NewChatTip: Tip {
    var title: Text {
        Text("Long Tap Shortcut")
    }
    
    var message: Text? {
        Text("Quickly access all available chat models by holding the \(Image(systemName: "square.and.pencil")) button. Configure visible models in settings")
    }

    var options: [Option] {
        MaxDisplayCount(2)
    }
    
    var image: Image? {
        Image(systemName: "square.and.pencil")
            .resizable()
    }
}

struct ImageGenToolTip: Tip {
    var title: Text {
        Text("Save to Device")
    }
    
    var message: Text? {
        Text("Images generated here are temporary. Save them to your device using the \(Image(systemName: "square.and.arrow.down")) button")
    }
    
    var image: Image? {
        Image(systemName: "square.and.arrow.down")
    }
    
    var options: [Option] {
        MaxDisplayCount(2)
    }
}

struct ContextMenuTip: Tip {
    var title: Text {
        Text("Context Menu")
    }
    
    var message: Text? {
        Text("Right click on messages to access more settings.")
    }
    
    #if os(macOS)
    var image: Image? {
        Image(systemName: "contextualmenu.and.cursorarrow")
    }
    #endif
    
    var options: [Option] {
        MaxDisplayCount(2)
    }
}

struct AudioUploadingTip: Tip {
    var title: Text {
        Text("Audio Files")
    }
    
    var message: Text? {
        Text("Uploading audio files may take a moment. Please wait a moment after sending the message.")
    }
    
    var image: Image? {
        Image(systemName: "waveform")
    }
    
    var options: [Option] {
        MaxDisplayCount(2)
    }
}

struct TemporaryChatTip: Tip {
    var title: Text {
        Text("Temporary Chat")
    }
    
    var message: Text? {
        Text("Click \(Image(systemName: "square.and.arrow.down")) button on top right of window to save this chat")
    }
    
    var image: Image? {
        Image(systemName: "square.and.arrow.down")
    }
}
