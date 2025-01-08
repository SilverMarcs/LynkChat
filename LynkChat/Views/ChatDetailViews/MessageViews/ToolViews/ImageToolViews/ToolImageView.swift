//
//  ToolImageView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI
import TipKit

struct ToolImageView: View {
    var urlStr: String?
    @State private var isHovering = true
    @State private var showCheckmark = false
    
    var body: some View {
        if let urlStr = urlStr {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: urlStr)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .popoverTip(ImageGenToolTip())
                    } else if phase.error != nil {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.red.quinary)
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.red)
                                .frame(width: 75, height: 75)
                        }
                    } else {
                        ToolImagePlaceholderView()
                    }
                }
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                if isHovering {
                    Button(action: saveImage) {
                        Image(systemName: showCheckmark ? "checkmark.circle.fill" : "square.and.arrow.up.circle.fill")
                            .font(.largeTitle)
                            .rotationEffect(.degrees(showCheckmark ? 0 : 180))
                        
                    }
                    .foregroundStyle(.white, .black.tertiary)
                    .buttonStyle(.plain)
                    .padding(10)
                }
            }
            #if os(macOS)
            .onHover { isHovering = $0 }
            #endif
        } else {
            ToolImagePlaceholderView()
        }
    }
    
    func saveImage() {
        guard let urlStr = urlStr, let url = URL(string: urlStr) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            ImageSaveUtil.saveImage(data: data) { success in
                DispatchQueue.main.async {
                    if success {
                        showCheckmark = true
                        
                        // Revert back to the original icon after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCheckmark = false
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
}

#Preview {
    ToolImageView(urlStr: "https://picsum.photos/200")
        .padding()
}
