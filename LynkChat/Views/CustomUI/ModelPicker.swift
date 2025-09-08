//
//  ModelPicker.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ModelPicker: View {
    @Binding var selectedModel: ChatModel
    var label: String = "Model"
    
    var body: some View {
        Picker(selection: $selectedModel) {
            ForEach(ChatModel.allCases, id: \.self) { model in
                Label(model.name, image: model.imageName)
                    .labelStyle(.titleAndIcon)
                    .tag(model)
            }
        } label: {
            Label("Model", image: selectedModel.imageName)
                .labelStyle(.titleAndIcon)
        }
        .menuOrder(.fixed)
    }
}


struct ModelMenuPicker: View {
    @Binding var selectedModels: Set<ChatModel>
    @State var showingPopover: Bool = false
    
    var body: some View {
        Button {
            var transaction = Transaction(animation: .none)
             transaction.disablesAnimations = true
             withTransaction(transaction) {
                 showingPopover.toggle()
             }
        } label: {
            if selectedModels.count == 1 {
                Label(labelText, image: selectedModels.first?.imageName ?? "cpu")
                    .labelStyle(.titleAndIcon)
            } else if selectedModels.count > 1 {
                ForEach(selectedModels.sortedByName()) { model in
                    Label(labelText, image: model.imageName)
                        .foregroundStyle(Color(hex: model.color))
                        .labelStyle(.iconOnly)
                }
            }
        }
        .popover(isPresented: $showingPopover) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(ChatModel.allCases, id: \.self) { model in
                    Toggle(isOn: Binding(
                        get: { selectedModels.contains(model) },
                        set: { isOn in
                            if isOn {
                                selectedModels.insert(model)
                            } else {
                                selectedModels.remove(model)
                            }
                        }
                    )) {
                        Label(model.name, image: model.imageName)
                    }
                    .toggleStyle(IconTextCheckmarkToggleStyle())
                    .disabled(selectedModels.count == 1 && selectedModels.contains(model))
                }
            }
            .padding(8)
        }
    }
    
    private var labelText: String {
        switch selectedModels.count {
        case 0:
            return "No Models"
        case 1:
            return selectedModels.first?.name ?? "1 Model"
        default:
            return "\(selectedModels.count) Models"
        }
    }
}

private extension Set where Element == ChatModel {
    func sortedByName() -> [ChatModel] {
        Array(self).sorted { $0.name < $1.name }
    }
}


struct IconTextCheckmarkToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        HoverableButton {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: "checkmark")
                    .imageScale(.small)
                    .opacity(configuration.isOn ? 1 : 0)
                configuration.label
                Spacer()
            }
            .contentShape(.rect) // better hit-testing
        }
    }
}

// A tiny helper to add hover background to any button label.
private struct HoverableButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label
    @State private var isHovering = false
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        Button(action: action) {
            label()
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isHovering ? AnyShapeStyle(.accent.secondary) : AnyShapeStyle(.clear))
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private var hoverFill: Color {
        // Use accent tint with low opacity for a subtle effect
        (isHovering ? .accentColor.opacity(scheme == .dark ? 0.18 : 0.12) : .clear)
    }
}
