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
        imagePicker.allowsEditing = false
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
            if let activeChat = ChatVM.shared.activeChat {
                chat = activeChat
            } else {
                // TODO: use modelactor here
                chat = ChatVM.shared.createNewChat()
            }
            
            try? await chat.inputManager.processData(
                imageData,
                fileType: .image,
                fileName: "Camera_\(UUID().uuidString)"
            )
        
            AppConfig.shared.showCamera = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        AppConfig.shared.showCamera = false
    }
}
