//
//  Scroller.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

enum Scroller<ID: Hashable> {
    // Preferred: pass a proxy directly
    static func scroll(to anchor: UnitPoint, of id: ID, with proxy: ScrollViewProxy?, animated: Bool = true, delay: TimeInterval = 0.0) {
        guard let proxy else { return }
        
        let action = {
            if animated {
                withAnimation { proxy.scrollTo(id, anchor: anchor) }
            } else {
                proxy.scrollTo(id, anchor: anchor)
            }
        }
        
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
    
    static func scrollToBottom(with proxy: ScrollViewProxy?, id: ID = String.bottomID, animated: Bool = true, delay: TimeInterval = 0.0) {
        guard let proxy else { return }
        
        scroll(to: .bottom, of: id, with: proxy, animated: animated, delay: delay)
    }
}
