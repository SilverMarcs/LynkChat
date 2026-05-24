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
        let imageConfig = ImageConfigDefaults()
        
        if imageConfig.saveToPhotos {
            saveToPhotos(data: data, completion: completion)
        } else {
            saveToDownloads(data: data, completion: completion)
        }
    }
    
    private static func saveToPhotos(data: Data, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(false)
                return
            }

            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            }) { success, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                completion(success)
            }
        }
    }
    
    private static func saveToDownloads(data: Data, completion: @escaping (Bool) -> Void) {
        guard let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
//            print("Unable to access Downloads directory")
            completion(false)
            return
        }
        
        let fileName = UUID().uuidString + "_image.png"
        let fileURL = downloadsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            completion(true)
        } catch {
            completion(false)
        }
    }
}
