//
//  String++.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import SwiftUI

extension String {
    nonisolated static let bottomID = "bottomID"
    static let testPrompt = "Respond with just the word Test"
    
    static var apiHost: String {
        if AppConfig().useLocalhost {
            "http://localhost:3000/api"
        } else {
            "https://lynkchat-server.vercel.app/api"
        }
    }
    
    func copyToPasteboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
        #else
        UIPasteboard.general.string = self
        #endif
    }
    
    static let onboarding: String = """
    # Welcome to LynkChat

    Thank you for downloading! We're excited to have you explore what our app can do.

    ## Getting Started

    You're all set with our free tier, which gives you access to our core AI capabilities. This lets you experience the assistant's helpfulness before deciding if our premium features are right for you.

    ## Available Features

    - **Chat with AI**: Ask questions, get creative help, or just have a conversation
    - **Web Search**: Get up-to-date information from across the internet directly in your chat
    - **Image Generation**: Create images based on your descriptions right in the conversation
    - **File & Image Sharing**: Drag and drop files or images into the chat, or use the "+" icon in the input bar

    ## Navigation Tips

    - Click the chat button at the top of your chat list to toggle between archived and starred conversations
    - Switch to image generation mode with the image button for a focused creative experience
    - Change AI models anytime from the chat input bar to suit your specific needs
    - Press **⌘+Space** to summon a floating chat panel that works anywhere in your OS
    - Many keyboard shortcuts are available - explore them in Settings (**⌘+,**)

    ## Premium Experience

    When you're ready to unlock our most advanced models and additional capabilities, our subscription plans are available to enhance your experience. Premium subscribers enjoy higher usage limits and access to our most powerful models.

    Ready to explore? Start chatting below!
    """
}
