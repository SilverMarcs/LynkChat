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
        HStack(spacing: 4) {
            Image(platformImage: typedData.imageName)
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
        .frame(maxWidth: 200)
        .padding(2)
    }
}
