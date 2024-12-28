//
//  ChatModelList.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ChatModelList: View {
    var body: some View {
        Form {
            ForEach(ChatModel.allCases) { model in
                // TODO: Table here
                HStack {
                    ModelImage(model: model)
                        
                    Text(model.name)
                    
                    Spacer()
                }
            }
        }
        .formStyle(.grouped)
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    ChatModelList()
}
