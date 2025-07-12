//
//  Environment++.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var isReplying = false
    @Entry var searchText = ""
    @Entry var chat: Chat = .mockChat // TODO: must make sure this is not used
    @Entry var windowType: WindowType = .chats // TODO: must make sure this is not used
    @Entry var imageSearchText: String = ""
    @Entry var chatSearchText: String = "" // not used atm
}
