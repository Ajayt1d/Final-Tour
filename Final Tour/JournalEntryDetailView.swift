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
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title & Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        if isEditing {
                            TextField("Title", text: $editedTitle)
                                .font(.title)
                                .fontWeight(.bold)
                        } else {
                            Text(entry.title)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        Text(entry.date.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(15)
                    
                    // Mood Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mood")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(EntryMood.allCases, id: \.self) { mood in
                                    Button(action: {
                                        if isEditing {
                                            editedMood = mood
                                        }
                                    }) {
                                        VStack(spacing: 4) {
                                            Text(mood.emoji)
                                                .font(.title2)
                                            Text(mood.rawValue)
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(isEditing ? (editedMood == mood ? mood.color.opacity(0.2) : Color.clear) : (entry.mood == mood ? mood.color.opacity(0.2) : Color.clear))
                                        .foregroundColor(isEditing ? (editedMood == mood ? mood.color : .gray) : (entry.mood == mood ? mood.color : .gray))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(isEditing ? (editedMood == mood ? mood.color : Color.gray.opacity(0.3)) : (entry.mood == mood ? mood.color : Color.gray.opacity(0.3)), lineWidth: 1)
                                        )
                                    }
                                    .disabled(!isEditing)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(15)
                    
                    // Content Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comments")
                            .font(.headline)
                        
                        if isEditing {
                            TextEditor(text: $editedContent)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        } else {
                            Text(entry.content)
                                .lineSpacing(8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(15)
                    
                    // Imported Journey Stats (if available)
                    if let importedJourney = entry.importedJourney {
                        VStack(spacing: 15) {
                            // Add Journey Title
                            HStack {
                                Text(importedJourney.title)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(importedJourney.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
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
                    
                    // Photos Section
                    if !editedImages.isEmpty || (entry.images?.isEmpty == false) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Photos")
                                .font(.headline)
                            
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
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(15)
                    }
                }
                .padding()
            }
            
            // Delete Button
            if !isEditing {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Delete Entry")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(25)
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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