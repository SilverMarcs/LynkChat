//
//  ImageCameraView.swift
//  LynkChat
//
//  Captures a photo and assigns it to ImageSession.inputImages
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageCameraView: UIViewControllerRepresentable {
    let session: ImageSession

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        #if !os(visionOS)
        imagePicker.sourceType = .camera
        #endif
        imagePicker.showsCameraControls = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImageCameraView

        init(parent: ImageCameraView) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage,
                  let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
                picker.dismiss(animated: true)
                return
            }

            parent.session.inputImages = [imageData]
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
