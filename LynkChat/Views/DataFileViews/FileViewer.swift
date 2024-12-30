//
//  PDFViewer.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/20/24.
//

import SwiftUI

struct FileViewer: View {
    let typedData: TypedData
    
    var body: some View {
        GroupBox {
            HStack(spacing: 4) {
                Image(platformImage: typedData.imageName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 27, height: 27)
                
                VStack(alignment: .leading) {
                    Text((typedData.fileName as NSString).deletingPathExtension)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text("\(typedData.fileType.fileExtension.uppercased())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .frame(width: 135, height: 28)
        }
        .groupBoxStyle(PlatformGroupBoxStyle())
    }
}
