//
//  SnagListView.swift
//  SnaGCapture
//
//  Main list view for displaying and managing snags
//

import SwiftUI
import SwiftData

@MainActor
struct SnagListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Snag.updatedAt, order: .reverse) private var snags: [Snag]
    
    @State private var searchText = ""
    @State private var showingAddSnag = false
    @State private var selectedSnag: Snag?
    
    private var filteredSnags: [Snag] {
        if searchText.isEmpty {
            return snags
        }
        return snags.filter { snag in
            snag.title.localizedCaseInsensitiveContains(searchText) ||
            snag.location.localizedCaseInsensitiveContains(searchText) ||
            snag.notes.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if snags.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredSnags) { snag in
                            NavigationLink(value: snag) {
                                SnagRowView(snag: snag)
                            }
                        }
                        .onDelete(perform: deleteSnags)
                    }
                    .searchable(text: $searchText, prompt: "Search snags")
                }
            }
            .navigationTitle("Snags")
            .navigationDestination(for: Snag.self) { snag in
                SnagDetailView(snag: snag)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSnag = true
                    } label: {
                        Label("Add Snag", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSnag) {
                AddSnagView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 70))
                .foregroundStyle(.green)
            
            Text("No Snags")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("Tap the + button to add your first snag")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    private func deleteSnags(at offsets: IndexSet) {
        for index in offsets {
            let snag = filteredSnags[index]
            
            // Delete associated photos from disk
            for photo in snag.photos {
                try? SnagImageStore.shared.deleteImage(filename: photo.filename)
            }
            
            // Delete from SwiftData
            modelContext.delete(snag)
        }
    }
}

// MARK: - Snag Row View

struct SnagRowView: View {
    let snag: Snag
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(snag.title)
                    .font(.headline)
                
                Spacer()
                
                priorityBadge
            }
            
            if !snag.location.isEmpty {
                Label(snag.location, systemImage: "location")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                statusBadge
                
                if snag.photoCount > 0 {
                    Label("\(snag.photoCount)", systemImage: "photo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(snag.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var priorityBadge: some View {
        Text(snag.priority.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priorityColor)
            .cornerRadius(4)
    }
    
    private var statusBadge: some View {
        Text(snag.status.rawValue)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray5))
            .cornerRadius(4)
    }
    
    private var priorityColor: Color {
        switch snag.priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Add Snag View

@MainActor
struct AddSnagView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var notes = ""
    @State private var location = ""
    @State private var priority: SnagPriority = .medium
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                } header: {
                    Text("Basic Info")
                }
                
                Section {
                    Picker("Priority", selection: $priority) {
                        ForEach(SnagPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Priority")
                }
                
                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("New Snag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSnag()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveSnag() {
        let snag = Snag(
            title: title,
            notes: notes,
            location: location,
            priority: priority,
            status: .open
        )
        
        modelContext.insert(snag)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save snag: \(error.localizedDescription)"
            showingError = true
        }
    }
}

// MARK: - Previews

#Preview("Snag List - With Data") {
    let container = try! ModelContainer(
        for: Snag.self, SnagPhoto.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    for snag in Snag.sampleSnags() {
        container.mainContext.insert(snag)
    }
    
    return SnagListView()
        .modelContainer(container)
}

#Preview("Snag List - Empty") {
    let container = try! ModelContainer(
        for: Snag.self, SnagPhoto.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    return SnagListView()
        .modelContainer(container)
}

#Preview("Add Snag Sheet") {
    let container = try! ModelContainer(
        for: Snag.self, SnagPhoto.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    return AddSnagView()
        .modelContainer(container)
}
