# Quick Start Guide

## Getting Started in Xcode

### Option 1: Create New Project (Fastest)

1. **Open Xcode** (Xcode 15+)

2. **Create New Project**:
   - File → New → Project
   - Choose **Multiplatform** → **App**
   - Click **Next**

3. **Configure Project**:
   ```
   Product Name: SnaGCapture
   Team: (Your Team)
   Organization Identifier: uk.kjdev
   Bundle Identifier: uk.kjdev.SnaGCapture
   Interface: SwiftUI
   Storage: SwiftData
   Language: Swift
   ```

4. **Save Location**:
   - Choose a location (e.g., Desktop)
   - Click **Create**

5. **Replace Default Files**:
   - Close Xcode
   - Delete the auto-generated `SnaGCapture` folder
   - Copy this repository's `SnaGCapture` folder to the project directory
   - Copy `SnaGCaptureTests` and `SnaGCaptureUITests` folders
   - Open the `.xcodeproj` file

6. **Add Files to Target**:
   - Right-click on "SnaGCapture" in Project Navigator
   - Choose "Add Files to SnaGCapture..."
   - Select all folders (App, Models, Storage, Views, Assets.xcassets)
   - Ensure "Create groups" is selected
   - Check both iOS and macOS targets
   - Click "Add"

7. **Set Deployment Targets**:
   - Click project in Navigator
   - Under "Deployment Info":
     - iOS: 17.0
     - macOS: 14.0

8. **Build & Run** (⌘R)

### Option 2: Using Project File Generator

If you have [XcodeGen](https://github.com/yonaskolb/XcodeGen) installed:

```bash
# Install XcodeGen (if not already installed)
brew install xcodegen

# Navigate to project directory
cd /path/to/SnaGCapture

# Generate Xcode project
xcodegen generate

# Open project
open SnaGCapture.xcodeproj
```

Then build and run (⌘R).

## First Run

1. **Select Target**:
   - iOS: Choose iPhone 15 Pro (or any iOS 17+ simulator)
   - macOS: Choose "My Mac"

2. **Run** (⌘R)

3. **Expected Behavior**:
   - App launches with empty snag list
   - "No Snags" message with checkmark icon
   - Three tabs: Snags, Settings, About
   - "+" button to add first snag

## Basic Usage

### Create Your First Snag

1. Tap **+** button (top right)
2. Enter:
   - Title: "Cracked tile"
   - Location: "Bathroom 2"
   - Priority: High
   - Notes: "Large crack, needs replacement"
3. Tap **Save**

### Add Photos

1. Tap the snag in the list
2. Tap **Add First Photo**
3. Choose:
   - **Take Photo** (iOS device only)
   - **Choose from Library** (iOS/macOS)
4. Select/capture image
5. Photo appears as thumbnail

### Search Snags

1. Pull down to reveal search bar (iOS)
2. Type search term
3. Results filter in real-time

### Delete Snag

1. Swipe left on snag (iOS)
2. Tap **Delete**
3. Confirm deletion
4. All photos removed

## Testing

### Run Unit Tests

```
Product → Test (⌘U)
```

Tests include:
- Image storage save/load/delete
- Model creation and persistence
- Relationship cascade deletes

### Run UI Tests

```
Product → Test (⌘U)
```

UI tests verify:
- Tab navigation
- Adding snags
- Detail view
- Search functionality

## Troubleshooting

### "No such module 'SwiftUI'" error
- **Cause**: Trying to build with `swift build` CLI
- **Solution**: Must use Xcode (SwiftUI requires Apple SDKs)

### Camera not working
- **Simulator**: Camera not available, use "Choose from Library"
- **Device**: Grant camera permission when prompted

### Build fails
- **Check**: Deployment target is iOS 17+ or macOS 14+
- **Fix**: Project → Targets → General → Minimum Deployments

### Missing files
- **Check**: All Swift files are added to target
- **Fix**: Select files → File Inspector → Target Membership

### Preview not working
- **Check**: Canvas is enabled (⌥⌘↵)
- **Try**: Clean Build Folder (⌘⇧K), then rebuild

## Project Structure

```
SnaGCapture/
├── App/                    # App entry point, main tabs
├── Models/                 # SwiftData models
├── Storage/                # Image file management
├── Views/                  # SwiftUI views
├── Assets.xcassets/        # Icons, colors
└── Info.plist              # Permissions

Tests/
├── SnaGCaptureTests/       # Unit tests
└── SnaGCaptureUITests/     # UI automation tests
```

## Key Features to Try

✅ **Multi-platform**: Test on iPhone, iPad, and Mac  
✅ **Search**: Real-time filtering of snags  
✅ **Photos**: Attach multiple photos per snag  
✅ **Priority**: Low/Medium/High color coding  
✅ **Status**: Track from Open → In Progress → Closed  
✅ **Persistence**: Data survives app restart  
✅ **Previews**: Each view has SwiftUI previews  

## Next Steps

- Review code in Views/ directory
- Check out SwiftUI previews (Canvas)
- Read DEVELOPMENT.md for detailed guide
- See README.md for architecture notes

## Need Help?

- See DEVELOPMENT.md for detailed setup
- Check README.md for architecture details
- Review inline code comments
- Xcode documentation: Help → Developer Documentation

---

**Ready to build!** Open in Xcode and press ⌘R to run.
