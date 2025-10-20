//
//  VideoSaveUtil.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/10/2025.
//

import SwiftUI
import Photos

enum VideoSaveUtil {
    static func saveVideo(data: Data, completion: @escaping (Bool) -> Void) {
        let imageConfig = ImageConfigDefaults()
        
        if imageConfig.saveToPhotos {
            saveToPhotos(data: data, completion: completion)
        } else {
            saveToDownloads(data: data, completion: completion)
        }
    }
    
    static func saveVideoFromURL(url: URL, completion: @escaping (Bool) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            saveVideo(data: data, completion: completion)
        }.resume()
    }
    
    private static func saveToPhotos(data: Data, completion: @escaping (Bool) -> Void) {
        // Save to temporary file first
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".mp4"
        let tempFileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempFileURL)
            
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    completion(false)
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempFileURL)
                }) { success, error in
                    // Clean up temp file
                    try? FileManager.default.removeItem(at: tempFileURL)
                    
                    if success {
                        completion(true)
                    } else if let error = error {
                        print("Error saving video to Photos: \(error.localizedDescription)")
                        completion(false)
                    }
                }
            }
        } catch {
            print("Error writing temp video file: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private static func saveToDownloads(data: Data, completion: @escaping (Bool) -> Void) {
        guard let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            completion(false)
            return
        }
        
        let fileName = UUID().uuidString + "_video.mp4"
        let fileURL = downloadsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            completion(true)
        } catch {
            print("Error saving video to Downloads: \(error.localizedDescription)")
            completion(false)
        }
    }
}
