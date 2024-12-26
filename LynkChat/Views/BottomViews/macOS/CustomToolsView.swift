////
////  CustomToolsView.swift
////  LynkChat
////
////  Created by Zabir Raihan on 22/12/2024.
////
//
//import SwiftUI
//
//struct CustomToolsView: View {
//    @Binding var tools: ChatConfigTools
//    let isGoogle: Bool
//    
//    var body: some View {
//        // TODO: GroupBox
//        HStack(spacing: 0) {
//            ForEach(ChatTool.allCases, id: \.self) { tool in
//                toolButton(
//                    systemImage: tool.icon,
//                    isEnabled: tools.isToolEnabled(tool),
//                    tintColor: tool.tintColor
//                ) {
//                    tools.setTool(tool, enabled: !tools.isToolEnabled(tool))
//                }
//            }
//        }
//        .background {
//            RoundedRectangle(cornerRadius: 6, style: .circular)
//                .fill(.background.tertiary)
//        }
//        .clipShape(RoundedRectangle(cornerRadius: 6, style: .circular))
//        .roundedRectangleOverlay(radius: 6, style: .circular)
//    }
//    
//    @ViewBuilder
//    private func toolButton(
//        systemImage: String,
//        isEnabled: Bool,
//        tintColor: Color,
//        action: @escaping () -> Void
//    ) -> some View {
//        Button(action: action) {
//            Image(systemName: systemImage)
//                .padding(4)
//                .imageScale(.medium)
//                .foregroundStyle(isEnabled ? AnyShapeStyle(tintColor) : AnyShapeStyle(.secondary))
//                .background {
//                    if isEnabled {
//                        Rectangle()
//                            .fill(tintColor.opacity(0.2))
//                    }
//                }
//                .contentShape(Rectangle())
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//
//#Preview {
//    @Previewable @State var tools = ChatConfigTools()
//    
//    CustomToolsView(tools: $tools, isGoogle: false)
//        .toggleStyle(.button)
//        .labelStyle(.iconOnly)
//        .buttonStyle(.borderless)
//        .padding()
//}
