//
//  SnaGCaptureApp.swift
//  SnaGCapture
//
//  Main application entry point with SwiftData container setup
//  Supports iOS 17+ and macOS 14+
//

import SwiftUI
import SwiftData

@main
struct SnaGCaptureApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Snag.self,
            SnagPhoto.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
            // CloudKit sync can be enabled here in the future:
            // cloudKitDatabase: .automatic
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Main Tab/Sidebar View

@MainActor
struct MainTabView: View {
    #if os(iOS)
    var body: some View {
        TabView {
            SnagListView()
                .tabItem {
                    Label("Snags", systemImage: "exclamationmark.triangle")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
    }
    #else
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink(destination: SnagListView()) {
                    Label("Snags", systemImage: "exclamationmark.triangle")
                }
                
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
                
                NavigationLink(destination: AboutView()) {
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("SnaGCapture")
        } detail: {
            SnagListView()
        }
    }
    #endif
}

// MARK: - Settings View

@MainActor
struct SettingsView: View {
    @State private var autoExportToPhotos = false
    @State private var showClearCacheAlert = false
    @State private var storageSize: String = "Calculating..."
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Auto-export to Photos", isOn: $autoExportToPhotos)
                        .disabled(true) // Placeholder for future feature
                } header: {
                    Text("Photo Export")
                } footer: {
                    Text("Automatically export new snag photos to your Photos library (coming soon)")
                }
                
                Section {
                    HStack {
                        Text("Storage Used")
                        Spacer()
                        Text(storageSize)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button(role: .destructive) {
                        showClearCacheAlert = true
                    } label: {
                        Label("Clear Image Cache", systemImage: "trash")
                    }
                } header: {
                    Text("Storage")
                } footer: {
                    Text("Clear all locally stored snag images. This cannot be undone.")
                }
            }
            .navigationTitle("Settings")
            .alert("Clear Image Cache?", isPresented: $showClearCacheAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearCache()
                }
            } message: {
                Text("This will delete all locally stored snag photos. This action cannot be undone.")
            }
            .task {
                updateStorageSize()
            }
        }
    }
    
    private func updateStorageSize() {
        let bytes = SnagImageStore.shared.getTotalStorageSize()
        storageSize = SnagImageStore.shared.formatStorageSize(bytes)
    }
    
    private func clearCache() {
        do {
            try SnagImageStore.shared.clearAllImages()
            updateStorageSize()
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
}

// MARK: - About View

@MainActor
struct AboutView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)
                    .padding(.top, 40)
                
                Text("SnaGCapture")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version 0.1")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Bundle ID", value: "uk.kjdev.SnaGCapture")
                    InfoRow(label: "Platform", value: "iOS 17+ / macOS 14+")
                    InfoRow(label: "Framework", value: "SwiftUI + SwiftData")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Text("Track construction defects and issues with photo documentation. Local-first with offline persistence.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Text("© 2025 KJ Development")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 20)
            }
            .navigationTitle("About")
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}
