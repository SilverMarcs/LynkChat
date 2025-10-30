//
//  ImageDetail.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageDetail: View {
    @Bindable var session: ImageSession

    var body: some View {
        #if os(macOS)
        ImageDetailMac(session: session)
        #else
        ImageDetailMobile(session: session)
        #endif
    }
}


#Preview {
    ImageDetail(session: .mockImageSession)
}
