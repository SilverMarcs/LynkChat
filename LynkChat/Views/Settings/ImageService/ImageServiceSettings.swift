//
//  ImageServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ImageServiceSettings: View {
    @State private var selectedTab: ImageServiceTab = .parameters
    
    var body: some View {
        Group {
            switch selectedTab {
            case .models:
                ImageModelList()
            case .parameters:
                ImageParametersSettings()
            }
        }
        .navigationTitle("Image Service")
        .toolbar {
            ToolbarItem(placement: .principal) {
                picker
            }
        }
    }
    
    var picker: some View {
        Picker("Tab", selection: $selectedTab) {
            ForEach(ImageServiceTab.allCases, id: \.self) { tab in
                Label(tab.rawValue, systemImage: tab.imageName)
                    .tag(tab)
                    .labelStyle(.titleOnly)
            }
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}

#Preview {
    ImageServiceSettings()
}
