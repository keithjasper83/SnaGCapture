//
//  SnagImageStore.swift
//  SnaGCapture
//
//  Handles saving and loading snag photos to/from Application Support directory
//  Cross-platform compatible for iOS and macOS
//

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

/// Manager for storing and retrieving snag images from the file system
@MainActor
final class SnagImageStore {
    static let shared = SnagImageStore()
    
    private let imageDirectory: URL
    
    private init() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        imageDirectory = appSupport.appendingPathComponent("SnagImages", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? fileManager.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
    }
    
    /// Save image data to disk and return the filename
    func saveImage(_ imageData: Data) throws -> String {
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = imageDirectory.appendingPathComponent(filename)
        
        try imageData.write(to: fileURL, options: .atomic)
        return filename
    }
    
    /// Load image data from disk by filename
    func loadImageData(filename: String) -> Data? {
        let fileURL = imageDirectory.appendingPathComponent(filename)
        return try? Data(contentsOf: fileURL)
    }
    
    /// Load a platform-appropriate image from disk
    #if canImport(UIKit)
    func loadImage(filename: String) -> UIImage? {
        guard let data = loadImageData(filename: filename) else { return nil }
        return UIImage(data: data)
    }
    #elseif canImport(AppKit)
    func loadImage(filename: String) -> NSImage? {
        guard let data = loadImageData(filename: filename) else { return nil }
        return NSImage(data: data)
    }
    #endif
    
    /// Delete an image file from disk
    func deleteImage(filename: String) throws {
        let fileURL = imageDirectory.appendingPathComponent(filename)
        try FileManager.default.removeItem(at: fileURL)
    }
    
    /// Delete all orphaned image files not referenced in the provided list
    func cleanupOrphanedFiles(keepFilenames: Set<String>) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil)
        
        for fileURL in contents {
            let filename = fileURL.lastPathComponent
            if !keepFilenames.contains(filename) {
                try fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    /// Clear all cached images (for settings/maintenance)
    func clearAllImages() throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil)
        
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    /// Get the total size of all stored images in bytes
    func getTotalStorageSize() -> Int64 {
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for fileURL in contents {
            if let resources = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resources.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        return totalSize
    }
    
    /// Format bytes to human-readable string
    func formatStorageSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Image Processing Helpers

extension SnagImageStore {
    /// Compress and prepare image data for storage
    #if canImport(UIKit)
    func prepareImageForStorage(_ image: UIImage, compressionQuality: CGFloat = 0.8) -> Data? {
        return image.jpegData(compressionQuality: compressionQuality)
    }
    
    /// Get image dimensions from UIImage
    func getImageDimensions(_ image: UIImage) -> (width: Int, height: Int) {
        return (Int(image.size.width), Int(image.size.height))
    }
    #elseif canImport(AppKit)
    func prepareImageForStorage(_ image: NSImage, compressionQuality: CGFloat = 0.8) -> Data? {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
    
    /// Get image dimensions from NSImage
    func getImageDimensions(_ image: NSImage) -> (width: Int, height: Int) {
        return (Int(image.size.width), Int(image.size.height))
    }
    #endif
}
