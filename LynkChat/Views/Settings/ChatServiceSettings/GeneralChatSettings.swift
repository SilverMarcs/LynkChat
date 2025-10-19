import SwiftUI

struct GeneralChatSettings: View {
    @State var config: ChatConfigDefaults = .init()
    
    var body: some View {
        Form {
            Section("Default Models") {
                ModelPicker(selectedModel: $config.defaultModel, label: "Chat")
                ModelPicker(selectedModel: $config.quickPanelDefaultModel, label: "Quick Panel")
            }
            
            Section("Parameters") {
                Picker("Behaviour", selection: $config.temperature) {
                    ForEach(Temperature.allCases, id: \.self) { option in
                        Text(option.name).tag(option)
                    }
                }
            }
            
            Section {
                TextEditor(text: $config.systemPrompt)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .frame(height: 70)
            } header: {
                HStack {
                    Text("System Prompt")
                    Spacer()
                    Button {
                        config.systemPrompt = String.systemPrompt
                    } label: {
                        Text("Default")
                            .fontWeight(.regular)
                    }
                }
            }
        }
        .navigationTitle("Chat Settings")
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettings()
}
