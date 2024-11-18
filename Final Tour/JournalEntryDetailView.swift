import SwiftUI
import UIKit

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entry: JournalEntry
    @State private var isEditing = false
    @State private var showingImportSheet = false
    @State private var showingImagePicker = false
    @State private var showingDeleteAlert = false
    @State private var showingFullScreenImage = false
    @State private var selectedImageIndex = 0
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedMood: EntryMood
    @State private var editedImages: [UIImage]
    @StateObject private var journeyStore = JourneyStore.shared
    var onDelete: (() -> Void)?
    
    init(entry: Binding<JournalEntry>, onDelete: (() -> Void)? = nil) {
        self._entry = entry
        self.onDelete = onDelete
        self._editedTitle = State(initialValue: entry.wrappedValue.title)
        self._editedContent = State(initialValue: entry.wrappedValue.content)
        self._editedMood = State(initialValue: entry.wrappedValue.mood)
        self._editedImages = State(initialValue: entry.wrappedValue.images ?? [])
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isEditing {
                    VStack(alignment: .leading, spacing: 20) {
                        TextField("Title", text: $editedTitle)
                            .font(.system(size: 24, weight: .bold))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack {
                            ForEach(EntryMood.allCases, id: \.self) { mood in
                                Button(action: {
                                    editedMood = mood
                                }) {
                                    Text(mood.emoji)
                                        .font(.system(size: 30))
                                        .opacity(editedMood == mood ? 1.0 : 0.5)
                                }
                            }
                            Spacer()
                            Button(action: {
                                showingImportSheet = true
                            }) {
                                Label("Import Ride", systemImage: "square.and.arrow.down")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        TextEditor(text: $editedContent)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        // Photo Section
                        if !editedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(editedImages.indices, id: \.self) { index in
                                        Image(uiImage: editedImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                Button(action: {
                                                    editedImages.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .background(Color.black.opacity(0.5))
                                                        .clipShape(Circle())
                                                }
                                                .padding(4),
                                                alignment: .topTrailing
                                            )
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Label("Add Photos", systemImage: "photo.on.rectangle.angled")
                        }
                    }
                } else {
                    // Title
                    Text(entry.title)
                        .font(.system(size: 24, weight: .bold))
                    
                    // Date
                    Text(entry.date.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Mood
                    Text(entry.mood.emoji)
                        .font(.system(size: 30))
                    
                    // Content/Notes section
                    VStack(alignment: .leading) {
                        Text("Comments")
                            .font(.headline)
                        if isEditing {
                            TextEditor(text: $editedContent)
                                .frame(minHeight: 200)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        } else {
                            Text(entry.content)
                                .lineSpacing(8)
                        }
                    }
                    
                    // Imported Ride Stats Card
                    if let importedJourney = entry.importedJourney {
                        VStack(spacing: 15) {
                            // Stats Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                StatCard(title: "Distance", value: importedJourney.distance, emoji: "🏍")
                                StatCard(title: "Duration", value: importedJourney.duration ?? "00:00", emoji: "⏱")
                                StatCard(title: "Average Speed", value: importedJourney.averageSpeed ?? "0 mph", emoji: "⚡️")
                                StatCard(title: "Location", value: importedJourney.location, emoji: "📍")
                            }
                            
                            // Conditions Row
                            HStack(spacing: 20) {
                                VStack {
                                    Text("Weather")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(importedJourney.weather.emoji)
                                        .font(.title)
                                }
                                
                                VStack {
                                    Text("Mood")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(importedJourney.mood.emoji)
                                        .font(.title)
                                }
                                
                                VStack {
                                    Text("Road")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(importedJourney.road.emoji)
                                        .font(.title)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(15)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !isEditing {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        entry.title = editedTitle
                        entry.content = editedContent
                        entry.mood = editedMood
                        entry.images = editedImages.isEmpty ? nil : editedImages
                    }
                    isEditing.toggle()
                }
            }
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this entry?")
        }
        .sheet(isPresented: $showingImportSheet) {
            NavigationView {
                List {
                    ForEach(journeyStore.journeys) { journey in
                        Button(action: {
                            importJourney(journey)
                            showingImportSheet = false
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(journey.title)
                                    .font(.headline)
                                HStack {
                                    Text(journey.date.formatted(date: .abbreviated, time: .shortened))
                                    Text("•")
                                    Text(journey.distance)
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .navigationTitle("Select Ride")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            showingImportSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImages: $editedImages)
        }
        .fullScreenCover(isPresented: $showingFullScreenImage) {
            ImageViewer(images: entry.images ?? [], currentIndex: selectedImageIndex) {
                showingFullScreenImage = false
            }
        }
    }
    
    private func importJourney(_ journey: Journey) {
        entry.importedJourney = journey
    }
}

struct ImageViewer: View {
    let images: [UIImage]
    @State private var currentIndex: Int
    let dismiss: () -> Void
    
    init(images: [UIImage], currentIndex: Int, dismiss: @escaping () -> Void) {
        self.images = images
        self._currentIndex = State(initialValue: currentIndex)
        self.dismiss = dismiss
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(images.indices, id: \.self) { index in
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFit()
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .background(Color.black)
        .overlay(
            Button(action: dismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
            }
            .padding(),
            alignment: .topTrailing
        )
    }
}

#Preview {
    NavigationView {
        JournalEntryDetailView(entry: .constant(JournalEntry(
            title: "Test Entry",
            date: Date(),
            content: "This is a test entry content",
            location: "Test Location",
            hasPhotos: false,
            mood: .happy
        )))
    }
} 