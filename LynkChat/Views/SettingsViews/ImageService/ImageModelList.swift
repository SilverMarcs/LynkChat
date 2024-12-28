//
//  ImageModelList.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ImageModelList: View {
    var body: some View {
        Form {
            ForEach(ImageModel.allCases) { model in
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

