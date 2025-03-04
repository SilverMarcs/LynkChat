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
                
                Text("Access multiple AI models in one place")
                    .font(.subheadline)
                
                Text("© \(Calendar.current.component(.year, from: Date())) LynkSphere")
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
}

#Preview {
    AboutSettings()
        .frame(width: 500)
}
