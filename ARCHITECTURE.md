# SnaGCapture - Architecture Documentation

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      SnaGCapture App                        │
│                   (iOS 17+ / macOS 14+)                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │         SwiftUI Interface Layer         │
        │  ┌──────────┐  ┌──────────┐  ┌───────┐ │
        │  │   Tabs   │  │ Sidebar  │  │ Forms │ │
        │  │  (iOS)   │  │  (macOS) │  │       │ │
        │  └──────────┘  └──────────┘  └───────┘ │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │            View Layer                   │
        │  ┌────────────┐  ┌─────────────────┐   │
        │  │ SnagList   │  │  SnagDetail     │   │
        │  │   View     │  │     View        │   │
        │  └────────────┘  └─────────────────┘   │
        │  ┌────────────┐  ┌─────────────────┐   │
        │  │  Camera    │  │   PhotoGrid     │   │
        │  │   View     │  │     View        │   │
        │  └────────────┘  └─────────────────┘   │
        └─────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    ▼                   ▼
        ┌──────────────────┐  ┌──────────────────┐
        │  SwiftData Layer │  │  Storage Layer   │
        │                  │  │                  │
        │  ┌────────────┐  │  │  ┌────────────┐ │
        │  │   Snag     │  │  │  │   Image    │ │
        │  │   Model    │  │  │  │   Store    │ │
        │  └────────────┘  │  │  └────────────┘ │
        │  ┌────────────┐  │  │                 │
        │  │ SnagPhoto  │  │  │                 │
        │  │   Model    │  │  │                 │
        │  └────────────┘  │  │                 │
        └──────────────────┘  └──────────────────┘
                    │                   │
                    ▼                   ▼
        ┌──────────────────┐  ┌──────────────────┐
        │  SQLite Database │  │  File System     │
        │  (SwiftData)     │  │  (App Support)   │
        └──────────────────┘  └──────────────────┘
```

## Component Breakdown

### 1. Application Layer
**File**: `App/SnaGCaptureApp.swift`

**Responsibilities**:
- App lifecycle management
- SwiftData container setup
- Tab/Sidebar navigation
- Settings view
- About view

**Key Classes**:
- `SnaGCaptureApp` - Main app struct
- `MainTabView` - Platform-specific navigation
- `SettingsView` - App settings
- `AboutView` - App information

### 2. View Layer

#### SnagListView
**File**: `Views/SnagListView.swift`

**Features**:
- Display all snags in list
- Search/filter functionality
- Add new snag
- Delete snags (swipe)
- Empty state placeholder

**SwiftData Integration**:
```swift
@Query(sort: \Snag.updatedAt, order: .reverse) 
private var snags: [Snag]
```

#### SnagDetailView
**File**: `Views/SnagDetailView.swift`

**Features**:
- Edit snag properties
- Add/remove photos
- Status & priority pickers
- Photo grid display
- Delete confirmation

**SwiftData Integration**:
```swift
@Bindable var snag: Snag
```

#### CameraView
**File**: `Views/CameraView.swift`

**Platform-Specific**:
- **iOS**: UIImagePickerController (camera + library)
- **macOS**: NSOpenPanel (file picker)

**Pattern**:
```swift
#if canImport(UIKit)
    // iOS implementation
#elseif canImport(AppKit)
    // macOS implementation
#endif
```

#### PhotoGridView
**File**: `Views/PhotoGridView.swift`

**Features**:
- Lazy grid of thumbnails
- Tap to preview fullscreen
- Delete individual photos
- Responsive layout

### 3. Model Layer
**File**: `Models/SnagModels.swift`

#### Snag Model
```swift
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
    
    @Relationship(deleteRule: .cascade)
    var photos: [SnagPhoto]
}
```

**Relationships**:
- One-to-many with SnagPhoto
- Cascade delete (deleting snag deletes photos)

#### SnagPhoto Model
```swift
@Model
final class SnagPhoto {
    var id: UUID
    var filename: String
    var createdAt: Date
    var width: Int?
    var height: Int?
    
    var snag: Snag?
}
```

**Relationships**:
- Many-to-one with Snag
- Inverse relationship for bidirectional navigation

### 4. Storage Layer
**File**: `Storage/SnagImageStore.swift`

**Responsibilities**:
- Save images to file system
- Load images from file system
- Delete images
- Cleanup orphaned files
- Calculate storage usage

**File Location**:
```
~/Library/Application Support/SnaGImages/
└── {UUID}.jpg
```

**Key Methods**:
```swift
func saveImage(_ imageData: Data) throws -> String
func loadImage(filename: String) -> PlatformImage?
func deleteImage(filename: String) throws
func cleanupOrphanedFiles(keepFilenames: Set<String>) throws
```

## Data Flow

### Creating a Snag

```
User Taps "+" Button
         │
         ▼
  AddSnagView Sheet Opens
         │
         ▼
  User Fills Form
         │
         ▼
  User Taps "Save"
         │
         ▼
  Create Snag Model
         │
         ▼
modelContext.insert(snag)
         │
         ▼
  modelContext.save()
         │
         ▼
SwiftData Persists to SQLite
         │
         ▼
  @Query Updates List
         │
         ▼
  SnagListView Refreshes
```

### Adding a Photo

```
User Opens Snag Detail
         │
         ▼
  Tap "Add Photo"
         │
         ▼
  CameraView Presents
         │
         ▼
User Selects/Captures Image
         │
         ▼
  onImageCaptured(imageData)
         │
         ▼
SnagImageStore.saveImage(imageData)
         │
         ▼
 Returns filename: "ABC-123.jpg"
         │
         ▼
Create SnagPhoto Model
         │
         ▼
  photo.snag = snag
  snag.photos.append(photo)
         │
         ▼
  modelContext.save()
         │
         ▼
SwiftData Persists Relationship
         │
         ▼
File System Stores Image
         │
         ▼
  @Bindable Updates UI
         │
         ▼
  PhotoGrid Displays
```

### Deleting a Snag

```
User Swipes Snag
         │
         ▼
  Delete Button Appears
         │
         ▼
  User Confirms Delete
         │
         ▼
 for photo in snag.photos:
    SnagImageStore.deleteImage(photo.filename)
         │
         ▼
  modelContext.delete(snag)
         │
         ▼
SwiftData Cascade Deletes SnagPhoto Records
         │
         ▼
  modelContext.save()
         │
         ▼
  @Query Updates
         │
         ▼
  SnagListView Refreshes
```

## Platform Abstraction

### Image Handling

```swift
#if canImport(UIKit)
typealias PlatformImage = UIKit.UIImage

func prepareImageForStorage(_ image: UIImage) -> Data? {
    return image.jpegData(compressionQuality: 0.8)
}
#elseif canImport(AppKit)
typealias PlatformImage = AppKit.NSImage

func prepareImageForStorage(_ image: NSImage) -> Data? {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData) else {
        return nil
    }
    return bitmap.representation(using: .jpeg, 
        properties: [.compressionFactor: 0.8])
}
#endif
```

### Navigation

```swift
#if os(iOS)
// Tab-based navigation
TabView {
    SnagListView()
        .tabItem { Label("Snags", systemImage: "...") }
}
#else
// Sidebar navigation (macOS)
NavigationSplitView {
    List {
        NavigationLink(destination: SnagListView()) {
            Label("Snags", systemImage: "...")
        }
    }
} detail: {
    SnagListView()
}
#endif
```

## State Management

### View-Level State

```swift
@State private var searchText = ""
@State private var showingAddSnag = false
```

**Usage**: Local UI state (search, sheets, alerts)

### Model Observation

```swift
@Query(sort: \Snag.updatedAt) private var snags: [Snag]
```

**Usage**: Observing SwiftData queries, auto-updates

### Model Binding

```swift
@Bindable var snag: Snag
```

**Usage**: Two-way binding to model properties

### Environment

```swift
@Environment(\.modelContext) private var modelContext
@Environment(\.dismiss) private var dismiss
```

**Usage**: Access shared resources

## Persistence Strategy

### SwiftData (Structured Data)
- Snag metadata (title, notes, location, etc.)
- SnagPhoto metadata (filename, dimensions)
- Relationships
- Indexes for queries

**Storage**: SQLite database in Application Support

### File System (Binary Data)
- JPEG image files
- Compressed at 80% quality
- Named by UUID
- Orphan cleanup on delete

**Storage**: Application Support/SnagImages/

## Testing Architecture

### Unit Tests

```
SnagImageStoreTests
├── testSaveAndLoadImage
├── testDeleteImage
├── testCleanupOrphanedFiles
├── testGetTotalStorageSize
├── testFormatStorageSize
└── testClearAllImages

SnagModelTests
├── testSnagCreation
├── testSnagPersistence
├── testSnagPhotoRelationship
├── testSnagCascadeDelete
├── testSnagTimestamps
├── testPriorityEnum
├── testStatusEnum
└── testSampleSnags
```

### UI Tests

```
SnagCaptureUITests
├── testLaunchApp
├── testNavigationTabs
├── testAddSnagWorkflow
├── testSnagDetailView
├── testSettingsView
├── testAboutView
└── testSearchFunctionality
```

## Future Architecture (CloudKit)

### Enabling CloudKit Sync

**1. Update ModelConfiguration**:
```swift
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .automatic  // Uncomment this
)
```

**2. Enable Capability**:
- Xcode → Signing & Capabilities
- Add "iCloud" capability
- Enable "CloudKit"

**3. Sync Behavior**:
```
Local SwiftData ←→ iCloud CloudKit
     ↓                    ↓
  SQLite              CloudKit DB
                          ↓
                   Other Devices
```

**4. Conflict Resolution**:
- Automatic via SwiftData
- Last-write-wins by default
- Can customize with merge policies

## Performance Considerations

### Image Loading
- Images loaded asynchronously via `.task {}`
- Thumbnails displayed while loading
- Cached in memory by platform image types

### Query Optimization
```swift
@Query(
    sort: \Snag.updatedAt, 
    order: .reverse
) private var snags: [Snag]
```
- Sorted at database level
- Efficient pagination support
- Automatic change tracking

### Memory Management
- `@MainActor` ensures UI updates on main thread
- Proper cleanup in `.onDisappear`
- Weak references where appropriate

## Security & Privacy

### Data Protection
- All data stored in app sandbox
- No network access (yet)
- No third-party analytics
- No telemetry

### Permissions
- Camera: Requested on first use
- Photo Library: Requested on first access
- File System: Sandboxed by default

### Future Considerations
- CloudKit encryption at rest
- App Transport Security for future APIs
- Keychain for future credentials

## Scalability

### Current Limits
- **Snags**: Effectively unlimited (SQLite limit ~2^63)
- **Photos per Snag**: Unlimited
- **Image Size**: Limited by device storage

### Optimization Opportunities
1. Thumbnail generation (currently loads full images)
2. Virtual scrolling for large lists
3. Image compression quality settings
4. Photo pagination in detail view
5. Search indexing for faster queries

## Build Configurations

### Debug
- SwiftData verbose logging
- SwiftUI preview support
- Debug symbols included

### Release
- Optimizations enabled
- Logging minimized
- Code signing required

## Directory Structure

```
SnaGCapture/
├── App/
│   └── SnaGCaptureApp.swift       # Entry point
├── Models/
│   └── SnagModels.swift           # Data models
├── Storage/
│   └── SnagImageStore.swift       # File I/O
├── Views/
│   ├── SnagListView.swift         # List UI
│   ├── SnagDetailView.swift       # Detail UI
│   ├── CameraView.swift           # Photo capture
│   └── PhotoGridView.swift        # Grid display
├── Assets.xcassets/               # Images/colors
├── Info.plist                     # Permissions
└── Resources/                     # Future assets

Tests/
├── SnaGCaptureTests/
│   ├── SnagImageStoreTests.swift
│   └── SnagModelTests.swift
└── SnaGCaptureUITests/
    └── SnagCaptureUITests.swift
```

## Deployment

### iOS
- Minimum: iOS 17.0
- Targets: iPhone, iPad
- Orientations: All supported

### macOS
- Minimum: macOS 14.0
- Targets: Apple Silicon, Intel
- Architecture: Universal binary

## Maintenance

### Adding New Features
1. Create model changes in `SnagModels.swift`
2. Add view in appropriate Views/ file
3. Update navigation in `SnaGCaptureApp.swift`
4. Add tests for new functionality
5. Update documentation

### Debugging Tools
- SwiftData debugging console
- Xcode Memory Graph Debugger
- Instruments (Time Profiler, Allocations)
- SwiftUI View Inspector

---

**Architecture Version**: 1.0  
**Last Updated**: 2025-11-09  
**Status**: Production Ready ✅
