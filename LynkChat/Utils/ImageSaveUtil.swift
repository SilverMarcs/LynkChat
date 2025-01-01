//
//  ImageSaveUtil.swift
//  LynkChat
//
//  Created by Zabir Raihan on 31/12/2024.
//

import SwiftUI
import Photos

enum ImageSaveUtil {
    static func saveImage(data: Data, completion: @escaping (Bool) -> Void) {
        let imageConfig = ImageModelConfig.shared
        
        if imageConfig.saveToPhotos {
            saveToPhotos(data: data, completion: completion)
        } else {
            saveToDownloads(data: data, completion: completion)
        }
    }
    
    private static func saveToPhotos(data: Data, completion: @escaping (Bool) -> Void) {
        guard let image = PlatformImage(data: data) else {
            print("Error creating image from data")
            completion(false)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("No access to photo library")
                completion(false)
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if success {
                    print("Image saved to Photos")
                    completion(true)
                } else if let error = error {
                    print("Error saving image to Photos: \(error)")
                    completion(false)
                }
            }
        }
    }
    
    private static func saveToDownloads(data: Data, completion: @escaping (Bool) -> Void) {
        guard let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            print("Unable to access Downloads directory")
            completion(false)
            return
        }
        
        let fileName = UUID().uuidString + "_image.png"
        let fileURL = downloadsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("Image saved to \(fileURL.path)")
            completion(true)
        } catch {
            print("Error saving image: \(error)")
            completion(false)
        }
    }
}
