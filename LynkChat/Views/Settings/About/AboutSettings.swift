//
//  AboutSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/11/2024.
//

import SwiftUI

struct AboutSettings: View {
    @Environment(GodMode.self) var godMode
    @State private var tapCount = 0
    @State private var showGodModeSheet = false

    var body: some View {
        Form {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Image("AppIconPng")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            tapCount += 1
                            if tapCount >= 5 {
                                tapCount = 0
                                showGodModeSheet = true
                            }
                        }
                        .popover(isPresented: $showGodModeSheet) {
                            GodModeActivationSheet()
                                .frame(width: 300)
                        }
                    Spacer()
                }

                Text("LynkChat")
                    .font(.title.bold())

                Text("Access multiple AI models in one place")
                    .font(.subheadline)

                Text("© \(String(Calendar.current.component(.year, from: Date()))) LynkSphere")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
            }
            
            Section("Connect") {
                LabeledContent{
                    Link("Product Page", destination: URL(string: "https://lynkSphere.com/products/lynkchat")!)
                } label: {
                    Text("\(Image(systemName: "apps.iphone")) Product")
                }
                
                LabeledContent{
                    Link("Company Website", destination: URL(string: "https://lynkSphere.com")!)
                } label: {
                    Text("\(Image(systemName: "link")) Visit")
                }
                
                LabeledContent {
                    Link("Follow on Instagram", destination: URL(string: "https://www.instagram.com/lynksphere")!)
                } label: {
                    Text("\(Image(systemName: "person")) Social")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("About")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    AboutSettings()
        .frame(width: 500)
}
