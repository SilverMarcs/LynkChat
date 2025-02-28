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
    var chatVM: ChatVM
    var chat: Chat? // The chat object for the quick panel
    private var currentHeightState: QuickPanelHeight = .collapsed()

    @discardableResult
    init(
        contentRect: NSRect = NSRect(x: 0, y: 0, width: 650, height: 57),
        backing: NSWindow.BackingStoreType = .buffered,
        defer flag: Bool = false,
        chatVM: ChatVM
    ) {
        self.chatVM = chatVM
        super.init(contentRect: contentRect,
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

        // Get or create the quick panel chat from the ChatVM
        self.chat = chatVM.getOrCreateQuickPanelChat()

        let hostingView = NSHostingView(
            rootView: QuickPanelView(
                chat: chat!, // Use the chat obtained from ChatVM
                updateHeightState: { [weak self] heightState in
                    self?.setHeightState(heightState)
                }
            )
            .ignoresSafeArea()
            .environment(chatVM)
        )

        let visualEffectView = NSVisualEffectView(frame: contentRect)
        visualEffectView.material = .sidebar
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.autoresizingMask = [.width, .height]

        visualEffectView.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor)
        ])

        contentView = visualEffectView

        heightConstraint = visualEffectView.heightAnchor.constraint(equalToConstant: contentRect.height)
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
            if chat?.currentThread.isEmpty == true && chat?.inputManager.dataFiles.isEmpty == true {
                setHeightState(.collapsed())
            } else {
                updateHeightStateBasedOnContent()
            }

            makeKeyAndOrderFront(nil)
        }
    }

    func updateHeightStateBasedOnContent() {
        guard let chat = chat else { return } // Use the window's chat

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
