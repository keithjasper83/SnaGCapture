# SnaGCapture

A local-first iOS and macOS application for tracking construction defects and issues with photo documentation.

## Overview

SnaGCapture is a multiplatform SwiftUI app that helps construction professionals document and track snags (defects, issues, or items requiring attention) with photo evidence. Built with SwiftData for offline-first persistence, it's designed to work seamlessly on iPhone, iPad, and Mac.

## Features

- **Create & Manage Snags**: Track issues with title, description, location, priority, and status
- **Photo Documentation**: Attach multiple photos to each snag with thumbnail grid view
- **Search & Filter**: Quickly find snags by title, location, or notes
- **Priority Levels**: Categorize snags as low, medium, or high priority
- **Status Tracking**: Monitor progress from open → in progress → closed
- **Offline First**: All data stored locally with SwiftData
- **Cross-Platform**: Native iOS 17+ and macOS 14+ support
- **No External Dependencies**: Pure SwiftUI + SwiftData implementation

## Technical Stack

- **Language**: Swift 5.10+
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Platforms**: iOS 17+, macOS 14+
- **Architecture**: MVVM with SwiftData models
- **Photo Storage**: Local file system (Application Support)

## Project Structure

```
SnaGCapture/
├── App/
│   └── SnaGCaptureApp.swift      # Main app entry, tabs/sidebar, settings, about
├── Models/
│   └── SnagModels.swift          # SwiftData models (Snag, SnagPhoto)
├── Storage/
│   └── SnagImageStore.swift      # Image file management
├── Views/
│   ├── SnagListView.swift        # List view with search
│   ├── SnagDetailView.swift      # Detail editing view
│   ├── CameraView.swift          # Photo capture/selection
│   └── PhotoGridView.swift       # Thumbnail grid component
├── Info.plist                     # Camera permissions
└── Resources/
```

## Building & Running

### Using Xcode

1. Open the project folder in Xcode (File → Open → select the `SnaGCapture` directory)
2. Xcode will automatically detect the Swift Package
3. Select your target device (iOS Simulator or Mac)
4. Build and run (⌘R)

### Using Swift Package Manager

```bash
# Build the package
swift build

# Run tests
swift test
```

## Testing

The project includes comprehensive test coverage:

- **Unit Tests**: `SnaGCaptureTests/`
  - `SnagImageStoreTests.swift` - Storage layer tests
  - `SnagModelTests.swift` - SwiftData model tests

- **UI Tests**: `SnaGCaptureUITests/`
  - `SnagCaptureUITests.swift` - End-to-end workflow tests

Run tests in Xcode with ⌘U or via command line:
```bash
swift test
```

## Usage

### Creating a Snag

1. Tap the "+" button in the Snags tab
2. Enter title, location, and notes
3. Set priority level
4. Tap "Save"

### Adding Photos

1. Open a snag from the list
2. Tap "Add Photo" or "Add First Photo"
3. Choose between camera (iOS) or file picker (macOS)
4. Photo is automatically saved and attached

### Managing Storage

Visit the Settings tab to:
- View total storage used by photos
- Clear image cache (removes all photos)

## Permissions

The app requires the following permissions (iOS):
- **Camera**: To capture photos of snags
- **Photo Library**: To select existing photos

These are declared in `Info.plist`.

## Future Roadmap

- ✅ Local-first persistence (Complete)
- ✅ Multi-photo support (Complete)
- ✅ Priority & status tracking (Complete)
- ⏳ CloudKit sync (Prepared, not implemented)
- ⏳ Export to Photos app
- ⏳ Map view for snag locations
- ⏳ PDF report generation

## Architecture Notes

### CloudKit Ready

The app is designed for future CloudKit integration. To enable:

1. Open `SnaGCaptureApp.swift`
2. Uncomment the `cloudKitDatabase` configuration:
```swift
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .automatic  // Uncomment this line
)
```
3. Configure CloudKit in your Apple Developer account
4. Enable CloudKit capability in Xcode

### Data Model

- **Snag**: Main entity with title, notes, location, priority, status, timestamps
- **SnagPhoto**: Photo attachment with filename and optional dimensions
- Cascade delete: Removing a snag deletes all associated photos

### Storage Strategy

- SwiftData handles structured data (metadata)
- Images stored as JPEG files in Application Support/SnagImages
- Orphaned files cleaned up when snags are deleted

## License

MIT License - See LICENSE file for details

## Version

**0.1** - Initial MVP Release
- Local-first snag tracking
- Multi-photo support
- iOS and macOS support
- Offline persistence

## Bundle ID

`uk.kjdev.SnaGCapture`

## Author

KJ Development © 2025
