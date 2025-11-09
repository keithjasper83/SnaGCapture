# Development Guide

## Opening in Xcode

This project is ready for manual import into Xcode. Follow these steps:

### Method 1: Create New Xcode Project (Recommended)

1. Open Xcode
2. File → New → Project
3. Choose **iOS** → **App** (or **macOS** → **App** for Mac-first development)
4. Configuration:
   - Product Name: `SnaGCapture`
   - Team: Your development team
   - Organization Identifier: `uk.kjdev`
   - Bundle Identifier: `uk.kjdev.SnaGCapture`
   - Interface: **SwiftUI**
   - Storage: **SwiftData**
   - Language: **Swift**
   - Deployment Target: iOS 17.0+ / macOS 14.0+
5. Save to a temporary location
6. Close Xcode
7. Copy all files from this repository's `SnaGCapture/` directory into the new project's source folder
8. Replace any default files (ContentView.swift, etc.) with our structure
9. Add `Info.plist` to the project if not automatically included
10. Ensure all Swift files are added to the target

### Method 2: Using XcodeGen (If Installed)

If you have [XcodeGen](https://github.com/yonaskolb/XcodeGen) installed:

```bash
cd /path/to/SnaGCapture
xcodegen generate
open SnaGCapture.xcodeproj
```

### Method 3: Manual Xcode Project Creation

1. Open Xcode
2. File → New → Project → Multiplatform → App
3. Configure as above
4. Manually add all source files:
   - Right-click project → Add Files to "SnaGCapture"
   - Select all Swift files from the repository
   - Ensure "Copy items if needed" is unchecked (files already in place)
   - Choose target(s) appropriately

## Project Structure

Ensure your Xcode project has this structure:

```
SnaGCapture/
├── App/
│   └── SnaGCaptureApp.swift
├── Models/
│   └── SnagModels.swift
├── Storage/
│   └── SnagImageStore.swift
├── Views/
│   ├── SnagListView.swift
│   ├── SnagDetailView.swift
│   ├── CameraView.swift
│   └── PhotoGridView.swift
├── Info.plist
└── Resources/
```

## Build Configuration

### iOS Target Settings
- Deployment Target: iOS 17.0+
- Supported Destinations: iPhone, iPad
- Capabilities: None required (File System and Camera permissions in Info.plist)

### macOS Target Settings
- Deployment Target: macOS 14.0+
- App Sandbox: Enable if distributing via Mac App Store
- File Access: User Selected Files (Read/Write)

### Info.plist Keys

Ensure these keys are present:
- `NSCameraUsageDescription` - Camera access for photos
- `NSPhotoLibraryUsageDescription` - Photo library access
- `NSPhotoLibraryAddUsageDescription` - Saving photos (future use)

## Running the App

### iOS Simulator
1. Select iPhone 15 Pro (or later) simulator
2. Product → Run (⌘R)
3. App should launch with empty snag list

### iOS Device
1. Connect device
2. Select device in scheme
3. Ensure signing is configured
4. Product → Run (⌘R)

### macOS
1. Select "My Mac" as destination
2. Product → Run (⌘R)
3. Grant permissions if prompted

## Testing

### Unit Tests
- Select test target
- Product → Test (⌘U)
- Or click diamond icon next to test class/method

### UI Tests
- Ensure simulator/device is selected
- Product → Test (⌘U)
- UI tests will launch app and perform automated interactions

## Common Issues

### "No such module 'SwiftUI'" Error
- This is expected when using Swift Package Manager CLI
- SwiftUI/SwiftData require Xcode and Apple SDKs
- Solution: Open in Xcode as described above

### Camera Not Working in Simulator
- Camera is not available in iOS Simulator
- Use "Choose from Library" option instead
- Or test on physical device

### Build Failures
- Ensure deployment target is iOS 17+ / macOS 14+
- Verify all files are added to correct targets
- Clean build folder: Product → Clean Build Folder (⌘⇧K)

## Debugging

### SwiftData Issues
- Check Model Container initialization in `SnaGCaptureApp.swift`
- Verify `@Model` macros on `Snag` and `SnagPhoto`
- Use Xcode's SwiftData debugging tools

### Image Storage Issues
- Check Application Support directory permissions
- Review `SnagImageStore` for file operation errors
- Test with `SnagImageStoreTests`

### UI Issues
- Use SwiftUI Previews for rapid iteration
- Each view has preview configurations
- Canvas: Editor → Canvas (⌥⌘↵)

## Development Workflow

1. **Add Feature Branch**
   ```bash
   git checkout -b feature/your-feature
   ```

2. **Make Changes**
   - Edit Swift files in Xcode
   - Test with previews and simulator
   - Write/update tests

3. **Test Thoroughly**
   - Run unit tests (⌘U)
   - Test on multiple devices/sizes
   - Verify iPad and Mac layouts

4. **Commit & Push**
   ```bash
   git add .
   git commit -m "Description"
   git push origin feature/your-feature
   ```

## Code Style

- Use SwiftUI best practices
- Follow Apple's Swift API Design Guidelines
- Prefer `@Bindable` over `@State` for model objects
- Use `@Query` for SwiftData fetches
- Keep views small and composable
- Add `@MainActor` to view models
- Use `#if canImport(UIKit)` for platform-specific code

## Future Development

### CloudKit Integration
1. Enable CloudKit in Capabilities
2. Uncomment `cloudKitDatabase: .automatic` in `SnaGCaptureApp.swift`
3. Test sync across devices
4. Add conflict resolution

### Export to Photos
1. Implement in `SnagDetailView`
2. Use `PHPhotoLibrary` framework
3. Request authorization
4. Save images with metadata

### Map View
1. Add MapKit import
2. Parse location strings to coordinates
3. Show snags on map
4. Enable navigation

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode)
- [Swift Style Guide](https://google.github.io/swift/)

## Support

For issues or questions, see the main README.md or create an issue in the repository.
