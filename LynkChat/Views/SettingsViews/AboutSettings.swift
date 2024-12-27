//
//  AboutSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/11/2024.
//

import SwiftUI

struct AboutSettings: View {
    var body: some View {
        Form {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Image("AppIconPng")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Spacer()
                }
                    
                Text("LynkChat")
                    .font(.title.bold())
                
                Text("Multi-LLM API Service in SwiftUI")
                    .font(.subheadline)
                
                Text("© 2024 LynkSphere")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Section("Connect") {
                LabeledContent{
                    Link("Company Website", destination: URL(string: "https://LynkSphere.com")!)
                } label: {
                    Text("\(Image(systemName: "link")) Visit")
                }
                
                LabeledContent {
                    Link("Follow on Instagram", destination: URL(string: "https://www.instagram.com/lynksphere")!)
                } label: {
                    Text("\(Image(systemName: "person")) Social Profile")
                }
            }
            
            Section("Acknowledgements") {
                ForEach(Acknowledgement.acknowledgements, id: \.name) { acknowledgement in
                    Link(destination: URL(string: acknowledgement.url)!) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(acknowledgement.name)
                                    .font(.headline)
                                Text(acknowledgement.description)
                                    .multilineTextAlignment(.leading)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("About")
        .toolbarTitleDisplayMode(.inline)
    }
    
//    func getAppVersion() -> String {
//        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
//           {
//            return "Version \(version)"
//        }
//        return "Version Unknown"
//    }
}

#Preview {
    AboutSettings()
        .frame(width: 500)
}
