//
//  SnagModels.swift
//  SnaGCapture
//
//  SwiftData models for snag tracking
//  Created for iOS 17+ and macOS 14+
//

import Foundation
import SwiftData

/// Priority levels for a snag
enum SnagPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

/// Status tracking for a snag
enum SnagStatus: String, Codable, CaseIterable {
    case open = "Open"
    case inProgress = "In Progress"
    case closed = "Closed"
}

/// Main snag model representing a construction defect or issue
@Model
final class Snag {
    var id: UUID
    var title: String
    var notes: String
    var location: String
    var priority: SnagPriority
    var status: SnagStatus
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \SnagPhoto.snag)
    var photos: [SnagPhoto]
    
    /// Computed property for photo count
    var photoCount: Int {
        photos.count
    }
    
    init(
        title: String = "",
        notes: String = "",
        location: String = "",
        priority: SnagPriority = .medium,
        status: SnagStatus = .open
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.location = location
        self.priority = priority
        self.status = status
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
        self.photos = []
    }
}

/// Photo attachment for a snag, storing file reference and metadata
@Model
final class SnagPhoto {
    var id: UUID
    var filename: String
    var createdAt: Date
    var width: Int?
    var height: Int?
    
    var snag: Snag?
    
    init(filename: String, width: Int? = nil, height: Int? = nil) {
        self.id = UUID()
        self.filename = filename
        self.createdAt = Date()
        self.width = width
        self.height = height
    }
}

// MARK: - Preview Seed Data

#if DEBUG
extension Snag {
    /// Generate sample snags for SwiftUI previews
    static func sampleSnags() -> [Snag] {
        let snag1 = Snag(
            title: "Cracked tile in bathroom",
            notes: "Large crack in floor tile near shower. Needs replacement.",
            location: "Unit 4B - Master Bathroom",
            priority: .high,
            status: .open
        )
        
        let snag2 = Snag(
            title: "Paint touch-up required",
            notes: "Minor scuffs on living room wall",
            location: "Unit 4B - Living Room",
            priority: .low,
            status: .inProgress
        )
        
        let snag3 = Snag(
            title: "Window seal leaking",
            notes: "Water seepage during heavy rain. Urgent fix needed.",
            location: "Unit 3A - Bedroom 2",
            priority: .high,
            status: .open
        )
        
        let snag4 = Snag(
            title: "Door handle loose",
            notes: "Front door handle wobbles. Tighten or replace.",
            location: "Unit 2C - Entry",
            priority: .medium,
            status: .closed
        )
        
        return [snag1, snag2, snag3, snag4]
    }
}
#endif
