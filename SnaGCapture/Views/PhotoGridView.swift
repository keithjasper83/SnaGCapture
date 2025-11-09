//
//  PhotoGridView.swift
//  SnaGCapture
//
//  Reusable grid component for displaying snag photos with thumbnails
//

import SwiftUI

@MainActor
struct PhotoGridView: View {
    let photos: [SnagPhoto]
    let onPhotoTap: (SnagPhoto) -> Void
    let onPhotoDelete: (SnagPhoto) -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(photos) { photo in
                PhotoThumbnailView(
                    photo: photo,
                    onTap: { onPhotoTap(photo) },
                    onDelete: { onPhotoDelete(photo) }
                )
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Photo Thumbnail View

@MainActor
struct PhotoThumbnailView: View {
    let photo: SnagPhoto
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var image: PlatformImage?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .aspectRatio(1, contentMode: .fit)
                    
                    if let image = image {
                        #if canImport(UIKit)
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        #elseif canImport(AppKit)
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        #endif
                    } else {
                        ProgressView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            
            Button {
                showingDeleteAlert = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .background(Circle().fill(.black.opacity(0.3)).padding(-4))
            }
            .buttonStyle(.plain)
            .padding(4)
        }
        .task {
            image = SnagImageStore.shared.loadImage(filename: photo.filename)
        }
        .alert("Delete Photo?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This photo will be permanently deleted.")
        }
    }
}

// MARK: - Previews

#Preview("Photo Grid") {
    let container = try! ModelContainer(
        for: Snag.self, SnagPhoto.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let snag = Snag.sampleSnags()[0]
    let photos = [
        SnagPhoto(filename: "sample1.jpg", width: 1024, height: 768),
        SnagPhoto(filename: "sample2.jpg", width: 1024, height: 768),
        SnagPhoto(filename: "sample3.jpg", width: 768, height: 1024),
        SnagPhoto(filename: "sample4.jpg", width: 1024, height: 768)
    ]
    
    photos.forEach { photo in
        photo.snag = snag
        container.mainContext.insert(photo)
    }
    snag.photos = photos
    container.mainContext.insert(snag)
    
    return Form {
        Section {
            PhotoGridView(
                photos: photos,
                onPhotoTap: { _ in print("Photo tapped") },
                onPhotoDelete: { _ in print("Photo deleted") }
            )
        } header: {
            Text("Photos")
        }
    }
    .modelContainer(container)
}
