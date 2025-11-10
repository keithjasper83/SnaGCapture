//
//  SnagModelTests.swift
//  SnaGCaptureTests
//
//  Unit tests for SwiftData models
//

import XCTest
import SwiftData
@testable import SnaGCapture

@MainActor
final class SnagModelTests: XCTestCase {
    
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUp() async throws {
        let schema = Schema([Snag.self, SnagPhoto.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
    }
    
    override func tearDown() async throws {
        container = nil
        context = nil
    }
    
    func testSnagCreation() throws {
        let snag = Snag(
            title: "Test Snag",
            notes: "Test notes",
            location: "Test location",
            priority: .high,
            status: .open
        )
        
        XCTAssertEqual(snag.title, "Test Snag")
        XCTAssertEqual(snag.notes, "Test notes")
        XCTAssertEqual(snag.location, "Test location")
        XCTAssertEqual(snag.priority, .high)
        XCTAssertEqual(snag.status, .open)
        XCTAssertTrue(snag.photos.isEmpty)
        XCTAssertEqual(snag.photoCount, 0)
    }
    
    func testSnagPersistence() throws {
        let snag = Snag(title: "Persistent Snag", location: "Location A")
        context.insert(snag)
        try context.save()
        
        let descriptor = FetchDescriptor<Snag>()
        let fetchedSnags = try context.fetch(descriptor)
        
        XCTAssertEqual(fetchedSnags.count, 1)
        XCTAssertEqual(fetchedSnags.first?.title, "Persistent Snag")
    }
    
    func testSnagPhotoRelationship() throws {
        let snag = Snag(title: "Snag with Photos")
        context.insert(snag)
        
        let photo1 = SnagPhoto(filename: "test1.jpg", width: 1024, height: 768)
        let photo2 = SnagPhoto(filename: "test2.jpg", width: 1024, height: 768)
        
        photo1.snag = snag
        photo2.snag = snag
        snag.photos = [photo1, photo2]
        
        context.insert(photo1)
        context.insert(photo2)
        try context.save()
        
        XCTAssertEqual(snag.photoCount, 2)
        XCTAssertEqual(snag.photos.count, 2)
        XCTAssertNotNil(photo1.snag)
        XCTAssertEqual(photo1.snag?.id, snag.id)
    }
    
    func testSnagCascadeDelete() throws {
        let snag = Snag(title: "Snag to Delete")
        context.insert(snag)
        
        let photo = SnagPhoto(filename: "test.jpg")
        photo.snag = snag
        snag.photos = [photo]
        context.insert(photo)
        try context.save()
        
        let snagID = snag.id
        let photoID = photo.id
        
        // Delete snag
        context.delete(snag)
        try context.save()
        
        // Verify snag is deleted
        let snagDescriptor = FetchDescriptor<Snag>(
            predicate: #Predicate { $0.id == snagID }
        )
        let fetchedSnags = try context.fetch(snagDescriptor)
        XCTAssertTrue(fetchedSnags.isEmpty)
        
        // Verify photo is also deleted (cascade)
        let photoDescriptor = FetchDescriptor<SnagPhoto>(
            predicate: #Predicate { $0.id == photoID }
        )
        let fetchedPhotos = try context.fetch(photoDescriptor)
        XCTAssertTrue(fetchedPhotos.isEmpty)
    }
    
    func testSnagTimestamps() throws {
        let beforeCreation = Date()
        
        let snag = Snag(title: "Timestamp Test")
        
        let afterCreation = Date()
        
        XCTAssertGreaterThanOrEqual(snag.createdAt, beforeCreation)
        XCTAssertLessThanOrEqual(snag.createdAt, afterCreation)
        XCTAssertEqual(snag.createdAt, snag.updatedAt)
    }
    
    func testPriorityEnum() throws {
        XCTAssertEqual(SnagPriority.allCases.count, 3)
        XCTAssertEqual(SnagPriority.low.rawValue, "Low")
        XCTAssertEqual(SnagPriority.medium.rawValue, "Medium")
        XCTAssertEqual(SnagPriority.high.rawValue, "High")
    }
    
    func testStatusEnum() throws {
        XCTAssertEqual(SnagStatus.allCases.count, 3)
        XCTAssertEqual(SnagStatus.open.rawValue, "Open")
        XCTAssertEqual(SnagStatus.inProgress.rawValue, "In Progress")
        XCTAssertEqual(SnagStatus.closed.rawValue, "Closed")
    }
    
    func testSampleSnags() throws {
        let samples = Snag.sampleSnags()
        XCTAssertGreaterThan(samples.count, 0)
        XCTAssertFalse(samples[0].title.isEmpty)
    }
}
