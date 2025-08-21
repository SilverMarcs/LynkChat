//
//  CameraView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/09/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        #if !os(visionOS)
        imagePicker.sourceType = .camera
        #endif
//        imagePicker.allowsEditing = true
        imagePicker.showsCameraControls = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    func makeCoordinator() -> CameraCoordinator {
        return Coordinator(picker: self)
    }
}

class CameraCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: CameraView
    
    init(picker: CameraView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.7) else { return }
        
        Task {
            let chat: Chat
            
            // Use existing active chat if available, otherwise create a new one
            if let activeChat = ChatVM.shared.activeChat {
                chat = activeChat
            } else {
                chat = ChatVM.shared.createNewChat(delay: true)
            }
            
            try? await chat.inputManager.processData(
                imageData,
                fileType: .image,
                fileName: "Camera_\(UUID().uuidString)"
            )
        
            await MainActor.run {
                AppSettings.shared.showCamera = false
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        Task {
            await MainActor.run {
                AppSettings.shared.showCamera = false
            }
        }
    }
}
