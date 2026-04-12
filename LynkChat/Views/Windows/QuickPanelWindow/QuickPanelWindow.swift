//
//  QuickPanelWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 12/07/2024.
//

import SwiftUI
import SwiftData

class QuickPanelWindow: NSPanel {
    private var heightConstraint: NSLayoutConstraint?
    private var chatVM: ChatVM
    private var godMode: GodMode
    var chat: Chat // The chat object for the quick panel
    private var currentHeightState: QuickPanelHeight = .collapsed()

    @discardableResult
    init(
        contentRect: NSRect = NSRect(x: 0, y: 0, width: 650, height: 57),
        backing: NSWindow.BackingStoreType = .buffered,
        defer flag: Bool = false,
        chatVM: ChatVM,
        godMode: GodMode
    ) {
        self.chatVM = chatVM
        self.godMode = godMode
        self.chat = chatVM.getOrCreateQuickPanelChat()
        
        super.init(contentRect: NSRect(x: 0, y: 0, width: 650, height: 57),
                   styleMask: [.nonactivatingPanel, .closable, .fullSizeContentView, .titled],
                   backing: backing,
                   defer: flag)
        
        self.identifier = NSUserInterfaceItemIdentifier("quickPanel")
        isFloatingPanel = true
        level = .floating
        collectionBehavior.insert(.fullScreenDisallowsTiling)
        titleVisibility = .hidden
        toolbar?.isVisible = false
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        backgroundColor = .clear

        // Get or create the quick panel chat from the ChatVM

        let hostingView = NSHostingView(
            rootView: QuickPanelView(
                chat: chat, // Use the chat obtained from ChatVM
                updateHeightState: { [weak self] heightState in
                    self?.setHeightState(heightState)
                }
            )
            .environment(chatVM)
            .environment(godMode)
            .ignoresSafeArea()
        )

        // Replace NSVisualEffectView with NSGlassEffectView (macOS 26+)
        let glassEffectView = NSGlassEffectView()
//        glassEffectView.cornerRadius = 30 // Example: set a default corner radius
//        glassEffectView.tintColor = .clear
        glassEffectView.autoresizingMask = [.width, .height]
        glassEffectView.contentView = hostingView

        contentView = glassEffectView

        heightConstraint = glassEffectView.heightAnchor.constraint(equalToConstant: contentRect.height)
        heightConstraint?.isActive = true
        self.contentMinSize = NSSize(width: contentRect.width, height: contentRect.height)
        self.contentMaxSize = NSSize(width: contentRect.width, height: 500)

        HotKeyManager.shared = HotKeyManager { [weak self] in
            self?.toggleVisibility()
        }

        self.center()
    }

    func toggleVisibility() {
        if chatVM.isQuickPanelPresented {
            close()
        } else {
            chatVM.isQuickPanelPresented = true

            // Explicitly collapse if chat is empty *before* showing
            if chat.currentThread.isEmpty == true && chat.inputManager.dataFiles.isEmpty == true {
                setHeightState(.collapsed())
            } else {
                updateHeightStateBasedOnContent()
            }

            makeKeyAndOrderFront(nil)
        }
    }

    func updateHeightStateBasedOnContent() {
        let newState: QuickPanelHeight

        if !chat.currentThread.isEmpty {
            newState = .expanded()
        } else if !chat.inputManager.dataFiles.isEmpty {
            newState = .files()
        } else {
            newState = .collapsed()
        }

        // Only update if state changed to avoid unnecessary animations
        if currentHeightState != newState {
            setHeightState(newState)
        }
    }

    func setHeightState(_ state: QuickPanelHeight) {
        currentHeightState = state
        updateHeight(to: state.value)
    }

    func updateHeight(to height: CGFloat) {
        guard let screenFrame = screen?.visibleFrame else { return }
        let currentFrame = frame
        let newFrame = NSRect(x: currentFrame.origin.x,
                              y: currentFrame.origin.y + (currentFrame.origin.y + currentFrame.height > screenFrame.maxY ? 0 : currentFrame.height - height),
                              width: currentFrame.width,
                              height: height)

        // Ensure the new frame is within the screen bounds
        let adjustedFrame = NSRect(
            x: max(screenFrame.minX, min(newFrame.origin.x, screenFrame.maxX - newFrame.width)),
            y: max(screenFrame.minY, min(newFrame.origin.y, screenFrame.maxY - newFrame.height)),
            width: newFrame.width,
            height: height
        )

        setFrame(adjustedFrame, display: true)
        contentView?.setFrameSize(NSSize(width: adjustedFrame.width, height: height))
        heightConstraint?.constant = height

        self.contentMinSize.height = height
        self.contentMaxSize.height = height
    }

    override func resignMain() {
        super.resignMain()
        close()
    }

    override func close() {
        chatVM.isQuickPanelPresented = false
        super.close()
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
}
