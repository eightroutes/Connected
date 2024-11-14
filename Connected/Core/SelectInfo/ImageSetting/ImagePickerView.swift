//
//  ImagePickerView.swift
//  Connected
//
//  Created by 정근호 on 11/14/24.
//

import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import CropViewController


struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    @Binding var showCropView: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
                parent.showCropView = true
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

struct CropViewControllerWrapper: UIViewControllerRepresentable {
    var image: UIImage
    @Binding var croppedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = context.coordinator
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        
        return cropViewController
    }
    
    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CropViewControllerDelegate {
        let parent: CropViewControllerWrapper
        
        init(_ parent: CropViewControllerWrapper) {
            self.parent = parent
        }
        
        func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            parent.croppedImage = image
            parent.isPresented = false
        }
        
        func cropViewControllerDidCancel(_ cropViewController: CropViewController) {
            parent.isPresented = false
        }
    }
}
