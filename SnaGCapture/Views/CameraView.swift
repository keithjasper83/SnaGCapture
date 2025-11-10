//
//  CameraView.swift
//  SnaGCapture
//
//  Platform-specific camera/photo picker implementation
//  iOS: PHPickerViewController
//  macOS: NSOpenPanel for file selection
//

import SwiftUI
import PhotosUI

#if canImport(UIKit)
import UIKit

@MainActor
struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    let onImageCaptured: (Data) -> Void
    
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var showingSourceChoice = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if showingSourceChoice {
                    VStack(spacing: 20) {
                        Text("Add Photo")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button {
                                sourceType = .camera
                                showingImagePicker = true
                                showingSourceChoice = false
                            } label: {
                                Label("Take Photo", systemImage: "camera.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Button {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                            showingSourceChoice = false
                        } label: {
                            Label("Choose from Library", systemImage: "photo.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerRepresentable(
                    sourceType: sourceType,
                    onImagePicked: { image in
                        if let imageData = image.jpegData(compressionQuality: 0.8) {
                            onImageCaptured(imageData)
                        }
                        dismiss()
                    },
                    onCancel: {
                        dismiss()
                    }
                )
            }
        }
    }
}

// MARK: - UIImagePickerController Wrapper

struct ImagePickerRepresentable: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerRepresentable
        
        init(_ parent: ImagePickerRepresentable) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            } else {
                parent.onCancel()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
    }
}

#elseif canImport(AppKit)
import AppKit

@MainActor
struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    let onImageCaptured: (Data) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("Select Photo")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Choose an image file to attach to this snag")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Choose File...") {
                    showFilePicker()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top)
        }
        .padding(40)
        .frame(minWidth: 300, minHeight: 250)
    }
    
    private func showFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image, .jpeg, .png, .heic]
        panel.message = "Select an image to attach"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let imageData = try? Data(contentsOf: url) {
                    onImageCaptured(imageData)
                    dismiss()
                }
            } else {
                dismiss()
            }
        }
    }
}
#endif

// MARK: - Previews

#Preview("Camera View") {
    CameraView { data in
        print("Image captured: \(data.count) bytes")
    }
}
