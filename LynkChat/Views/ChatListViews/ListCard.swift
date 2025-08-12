//
//  ListCard.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI

struct ListCard: View {
    var icon: String
    var iconColor: Color
    var title: String
    var count: String
    var action: () -> Void = {}
    
    var body: some View {
        Button {
            action()
        } label: {
            GroupBox {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: icon)
                            .font(.title3)

                        Spacer()
                        
                        Text(count)
                            .contentTransition(.numericText())
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Text(title)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .opacity(0.9)
                        .padding(.leading, 2)
                }
                .padding(2)
            }
            .background(iconColor.mix(with: .black, by: 0.1).gradient.opacity(0.7), in: RoundedRectangle(cornerRadius: 7))
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
