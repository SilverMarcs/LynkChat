//
//  HotKeyManager.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import AppKit
import Carbon

@safe class HotKeyManager {
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    
    private let hotKeySignature: UInt32 = 0x48554E47 // "HUNG"
    private let hotKeyID = UInt32(1)
    
    private let callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
        registerHotKey()
    }
    
    private func registerHotKey() {
        // Create hot key ID
        let hotKeyID = EventHotKeyID(signature: hotKeySignature, id: self.hotKeyID)
        
        // Register Command + Space
        let registerError = unsafe RegisterEventHotKey(
            UInt32(kVK_Space), // Space key
            UInt32(cmdKey), // Command modifier
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
        
        guard registerError == noErr else {
            print("Failed to register hot key")
            return
        }
        
        // Install event handler
        let eventSpec = [
            EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                         eventKind: UInt32(kEventHotKeyPressed))
        ]
        
        unsafe InstallEventHandler(
            GetEventDispatcherTarget(),
            { (_, event, _) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                let error = unsafe GetEventParameter(
                    event,
                    UInt32(kEventParamDirectObject),
                    UInt32(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                
                if error == noErr {
                    HotKeyManager.shared?.callback()
                    return noErr
                }
                
                return OSStatus(eventNotHandledErr)
            },
            1,
            eventSpec,
            nil,
            &eventHandler
        )
    }
    
    deinit {
        if let hotKeyRef = unsafe hotKeyRef {
            unsafe UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandler = unsafe eventHandler {
            unsafe RemoveEventHandler(eventHandler)
        }
    }
    
    // Singleton instance to keep it alive
    static var shared: HotKeyManager?
}
