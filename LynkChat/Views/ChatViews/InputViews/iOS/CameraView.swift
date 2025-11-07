//
//  CameraView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/09/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct CameraView: UIViewControllerRepresentable {
    let chat: Chat
    var isPresented: Binding<Bool>
    
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
        return CameraCoordinator(picker: self, chat: chat, isPresented: isPresented)
    }
}

class CameraCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: CameraView
    var chat: Chat
    var isPresented: Binding<Bool>
    
    init(picker: CameraView, chat: Chat, isPresented: Binding<Bool>) {
        self.picker = picker
        self.chat = chat
        self.isPresented = isPresented
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.7) else { return }
        
        Task {
            try? await chat.inputManager.processData(
                imageData,
                fileType: .jpeg,
                fileName: "Camera_\(UUID().uuidString).jpg"
            )
        
            await MainActor.run { self.isPresented.wrappedValue = false }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        Task {
            await MainActor.run { self.isPresented.wrappedValue = false }
        }
    }
}
