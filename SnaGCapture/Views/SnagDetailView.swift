//
//  SnagDetailView.swift
//  SnaGCapture
//
//  Detail view for viewing and editing a snag with photo management
//

import SwiftUI
import SwiftData

@MainActor
struct SnagDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var snag: Snag
    
    @State private var showingCamera = false
    @State private var showingDeleteAlert = false
    @State private var showingPhotoPreview = false
    @State private var selectedPhoto: SnagPhoto?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $snag.title)
                    .font(.headline)
                TextField("Location", text: $snag.location)
            } header: {
                Text("Basic Info")
            }
            
            Section {
                Picker("Status", selection: $snag.status) {
                    ForEach(SnagStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                
                Picker("Priority", selection: $snag.priority) {
                    ForEach(SnagPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
            } header: {
                Text("Status & Priority")
            }
            
            Section {
                TextEditor(text: $snag.notes)
                    .frame(minHeight: 100)
            } header: {
                Text("Notes")
            }
            
            Section {
                if snag.photos.isEmpty {
                    Button {
                        showingCamera = true
                    } label: {
                        Label("Add First Photo", systemImage: "camera")
                    }
                } else {
                    PhotoGridView(
                        photos: snag.photos,
                        onPhotoTap: { photo in
                            selectedPhoto = photo
                            showingPhotoPreview = true
                        },
                        onPhotoDelete: { photo in
                            deletePhoto(photo)
                        }
                    )
                    
                    Button {
                        showingCamera = true
                    } label: {
                        Label("Add Photo", systemImage: "camera")
                    }
                }
            } header: {
                Text("Photos (\(snag.photoCount))")
            }
            
            Section {
                HStack {
                    Text("Created")
                    Spacer()
                    Text(snag.createdAt, style: .date)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Last Updated")
                    Spacer()
                    Text(snag.updatedAt, style: .relative)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Metadata")
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Snag", systemImage: "trash")
                }
            }
        }
        .navigationTitle(snag.title.isEmpty ? "Snag Details" : snag.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCamera) {
            CameraView { imageData in
                addPhoto(imageData: imageData)
            }
        }
        .sheet(isPresented: $showingPhotoPreview) {
            if let photo = selectedPhoto {
                PhotoPreviewView(photo: photo)
            }
        }
        .alert("Delete Snag?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSnag()
            }
        } message: {
            Text("This will permanently delete this snag and all its photos.")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: snag.title) { oldValue, newValue in updateTimestamp() }
        .onChange(of: snag.notes) { oldValue, newValue in updateTimestamp() }
        .onChange(of: snag.location) { oldValue, newValue in updateTimestamp() }
        .onChange(of: snag.status) { oldValue, newValue in updateTimestamp() }
        .onChange(of: snag.priority) { oldValue, newValue in updateTimestamp() }
    }
    
    private func addPhoto(imageData: Data) {
        do {
            let filename = try SnagImageStore.shared.saveImage(imageData)
            
            #if canImport(UIKit)
            let image = UIImage(data: imageData)
            let dimensions = image.map { SnagImageStore.shared.getImageDimensions($0) }
            #elseif canImport(AppKit)
            let image = NSImage(data: imageData)
            let dimensions = image.map { SnagImageStore.shared.getImageDimensions($0) }
            #endif
            
            let photo = SnagPhoto(
                filename: filename,
                width: dimensions?.width,
                height: dimensions?.height
            )
            photo.snag = snag
            snag.photos.append(photo)
            modelContext.insert(photo)
            
            updateTimestamp()
            try modelContext.save()
        } catch {
            errorMessage = "Failed to add photo: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func deletePhoto(_ photo: SnagPhoto) {
        do {
            try SnagImageStore.shared.deleteImage(filename: photo.filename)
            snag.photos.removeAll { $0.id == photo.id }
            modelContext.delete(photo)
            updateTimestamp()
            try modelContext.save()
        } catch {
            errorMessage = "Failed to delete photo: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func deleteSnag() {
        // Delete all photos from disk
        for photo in snag.photos {
            try? SnagImageStore.shared.deleteImage(filename: photo.filename)
        }
        
        modelContext.delete(snag)
        try? modelContext.save()
    }
    
    private func updateTimestamp() {
        snag.updatedAt = Date()
    }
}

// MARK: - Photo Preview View

@MainActor
struct PhotoPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let photo: SnagPhoto
    
    @State private var image: PlatformImage?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let image = image {
                    #if canImport(UIKit)
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    #elseif canImport(AppKit)
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    #endif
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                image = SnagImageStore.shared.loadImage(filename: photo.filename)
            }
        }
    }
}

// MARK: - Platform Image Type Alias

#if canImport(UIKit)
typealias PlatformImage = UIKit.UIImage
#elseif canImport(AppKit)
typealias PlatformImage = AppKit.NSImage
#endif

// MARK: - Previews

#Preview("Snag Detail - With Photos") {
    let container = try! ModelContainer(
        for: Snag.self, SnagPhoto.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let snag = Snag.sampleSnags()[0]
    let photo1 = SnagPhoto(filename: "sample1.jpg", width: 1024, height: 768)
    let photo2 = SnagPhoto(filename: "sample2.jpg", width: 1024, height: 768)
    photo1.snag = snag
    photo2.snag = snag
    snag.photos = [photo1, photo2]
    
    container.mainContext.insert(snag)
    container.mainContext.insert(photo1)
    container.mainContext.insert(photo2)
    
    return NavigationStack {
        SnagDetailView(snag: snag)
    }
    .modelContainer(container)
}

#Preview("Snag Detail - No Photos") {
    let container = try! ModelContainer(
        for: Snag.self, SnagPhoto.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let snag = Snag.sampleSnags()[1]
    container.mainContext.insert(snag)
    
    return NavigationStack {
        SnagDetailView(snag: snag)
    }
    .modelContainer(container)
}
