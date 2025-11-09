//
//  SnagImageStoreTests.swift
//  SnaGCaptureTests
//
//  Unit tests for SnagImageStore save/load cycle
//

import XCTest
@testable import SnaGCapture

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@MainActor
final class SnagImageStoreTests: XCTestCase {
    
    var store: SnagImageStore!
    
    override func setUp() async throws {
        store = SnagImageStore.shared
        // Clean up any existing test files
        try? store.clearAllImages()
    }
    
    override func tearDown() async throws {
        // Clean up test files
        try? store.clearAllImages()
        store = nil
    }
    
    func testSaveAndLoadImage() async throws {
        // Create test image data
        let testData = createTestImageData()
        
        // Save image
        let filename = try store.saveImage(testData)
        XCTAssertFalse(filename.isEmpty, "Filename should not be empty")
        XCTAssertTrue(filename.hasSuffix(".jpg"), "Filename should have .jpg extension")
        
        // Load image data
        let loadedData = store.loadImageData(filename: filename)
        XCTAssertNotNil(loadedData, "Loaded data should not be nil")
        XCTAssertEqual(loadedData?.count, testData.count, "Loaded data size should match original")
        
        // Load image
        let image = store.loadImage(filename: filename)
        XCTAssertNotNil(image, "Loaded image should not be nil")
    }
    
    func testDeleteImage() async throws {
        // Save test image
        let testData = createTestImageData()
        let filename = try store.saveImage(testData)
        
        // Verify it exists
        XCTAssertNotNil(store.loadImageData(filename: filename))
        
        // Delete it
        try store.deleteImage(filename: filename)
        
        // Verify it's gone
        XCTAssertNil(store.loadImageData(filename: filename))
    }
    
    func testCleanupOrphanedFiles() async throws {
        // Save multiple test images
        let data1 = createTestImageData()
        let data2 = createTestImageData()
        let data3 = createTestImageData()
        
        let filename1 = try store.saveImage(data1)
        let filename2 = try store.saveImage(data2)
        let filename3 = try store.saveImage(data3)
        
        // Keep only filename1 and filename2
        let keepFilenames: Set<String> = [filename1, filename2]
        
        // Cleanup orphaned files
        try store.cleanupOrphanedFiles(keepFilenames: keepFilenames)
        
        // Verify kept files still exist
        XCTAssertNotNil(store.loadImageData(filename: filename1))
        XCTAssertNotNil(store.loadImageData(filename: filename2))
        
        // Verify deleted file is gone
        XCTAssertNil(store.loadImageData(filename: filename3))
    }
    
    func testGetTotalStorageSize() async throws {
        // Start with empty storage
        let initialSize = store.getTotalStorageSize()
        
        // Add some test images
        let testData = createTestImageData()
        _ = try store.saveImage(testData)
        _ = try store.saveImage(testData)
        
        // Check size increased
        let newSize = store.getTotalStorageSize()
        XCTAssertGreaterThan(newSize, initialSize)
    }
    
    func testFormatStorageSize() async throws {
        let size1 = store.formatStorageSize(1024)
        XCTAssertTrue(size1.contains("KB") || size1.contains("bytes"))
        
        let size2 = store.formatStorageSize(1024 * 1024)
        XCTAssertTrue(size2.contains("MB") || size2.contains("KB"))
    }
    
    func testClearAllImages() async throws {
        // Add some test images
        let testData = createTestImageData()
        _ = try store.saveImage(testData)
        _ = try store.saveImage(testData)
        
        // Verify storage is not empty
        XCTAssertGreaterThan(store.getTotalStorageSize(), 0)
        
        // Clear all
        try store.clearAllImages()
        
        // Verify storage is empty
        XCTAssertEqual(store.getTotalStorageSize(), 0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestImageData() -> Data {
        #if canImport(UIKit)
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.jpegData(compressionQuality: 0.8) ?? Data()
        #elseif canImport(AppKit)
        let size = NSSize(width: 100, height: 100)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.red.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
        image.unlockFocus()
        
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            return Data()
        }
        return jpegData
        #endif
    }
}
