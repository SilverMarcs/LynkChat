//
//  ListCard.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct ListCard: View {
    @Environment(\.appearsActive) var appearsActive
    
    var icon: String
    var iconColor: Color
    var title: String
    var count: String
    var action: () -> Void = {}
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(iconColor)

                    Spacer()
                    
                    Text(count)
                        .contentTransition(.numericText())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                
                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .opacity(0.9)
                    .padding(.leading, 2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.background.quaternary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        ListCard(icon: "tray.circle.fill", iconColor: .blue, title: "Chats", count: String(20))
        ListCard(icon: "photo.circle.fill", iconColor: .cyan, title: "Images", count: "0") {
            
        }
    }
    .background(.clear)
    .frame(width: 280, height: 100)
    .padding()
}
