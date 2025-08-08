//
//  ChatModelTable.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ChatModelTable: View {
    
    var body: some View {
        Form {
            Section("Models") {
                ForEach(ChatModel.allCases) { model in
                    HStack {
                        ModelImage(model: model)
                        Text(model.name)
                        
                        Spacer()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Chat Models")
    }
}

#Preview {
    ChatModelTable()
        .frame(maxWidth: .infinity)
}

//struct ModelCatalogView: View {
//    @StateObject private var modelConfig = ModelConfig.shared
//    @State private var hoveredModel: ChatModel?
//    @State private var selectedModel: ChatModel?
//    
//    var body: some View {
//        ScrollView {
//            LazyVGrid(columns: [
//                GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 20)
//            ], spacing: 20) {
//                ForEach(ChatModel.allCases) { model in
//                    ModelCard(model: model)
//                        .onHover { isHovered in
//                            withAnimation(.spring(response: 0.3)) {
//                                hoveredModel = isHovered ? model : nil
//                            }
//                        }
//                }
//            }
//            .padding(20)
//        }
//    }
//}
//
//struct ModelCard: View {
//    let model: ChatModel
//    @StateObject private var modelConfig = ModelConfig.shared
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // Header
//            HStack(spacing: 12) {
////                ModelImage(model: model)
//                Image(model.imageName)
//                    .font(.largeTitle)
//                    .foregroundColor(Color(hex: model.color))
//                    .background(
//                        Circle()
//                            .fill(Color(hex: model.color).opacity(0.1))
//                            .padding(-8)
//                    )
//                
//                VStack(alignment: .leading) {
//                    Text(model.name)
//                        .font(.title2.weight(.semibold))
//                    Text(model.group.rawValue.uppercased())
//                           .font(.subheadline)
//                           .foregroundStyle(.secondary)
//                }
//                
//                Spacer()
//                
//                Toggle("", isOn: modelConfig.binding(for: model))
//                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: model.color)))
//            }
//            .padding()
//            
//            Divider()
//            
////            // Features
//            VStack(alignment: .leading, spacing: 12) {
////                FeatureRow(icon: "puzzlepiece.extension",
////                          text: "Tools Support",
////                          isEnabled: model.supportsTool)
////                .foregroundStyle(.cyan)
//                
//                FeatureRow(icon: "photo.stack",
//                          text: "Image Analysis",
//                          isEnabled: model.supportedTypes.contains(.image))
//                .foregroundStyle(.cyan)
////
////                PriceTag(model: model)
//            }
//            .padding()
//        }
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(.background)
//                .shadow(color: .black.opacity(0.1), radius: 15, y: 5)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .strokeBorder(Color(hex: model.color).opacity(0.3), lineWidth: 1)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(hex: model.color).opacity(0.03))
//        )
//        .contentShape(RoundedRectangle(cornerRadius: 12))
//    }
//}
//
//struct FeatureRow: View {
//    let icon: String
//    let text: String
//    let isEnabled: Bool
//    
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: icon)
//                .font(.system(size: 16))
//            
//            Text(text)
////                .foregroundStyle(.secondary)
//            
//            Spacer()
//            
//            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
//                .foregroundStyle(isEnabled ? .green : .red)
//        }
//    }
//}
//
//struct PriceTag: View {
//    let model: ChatModel
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "dollarsign.circle.fill")
//                .foregroundStyle(.blue)
//            
//            Text("Price:")
//                .foregroundStyle(.secondary)
//            
//            Text("\(model.price.promptTokens)/\(model.price.completionTokens)")
//                .monospacedDigit()
//                .fontWeight(.medium)
//            
//            Spacer()
//        }
//    }
//}
