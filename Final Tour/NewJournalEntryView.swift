import SwiftUI
import UIKit

struct NewJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entries: [JournalEntry]
    @State private var title = ""
    @State private var content = ""
    @State private var mood: EntryMood = .happy
    @State private var showingImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var showingImportSheet = false
    @StateObject private var journeyStore = JourneyStore.shared
    @State private var importedJourney: Journey?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Title", text: $title)
                    }
                    
                    Section {
                        HStack {
                            ForEach(EntryMood.allCases, id: \.self) { mood in
                                Button(action: {
                                    self.mood = mood
                                }) {
                                    Text(mood.emoji)
                                        .font(.system(size: 30))
                                        .opacity(self.mood == mood ? 1.0 : 0.5)
                                }
                            }
                        }
                    }
                    
                    Section {
                        TextEditor(text: $content)
                            .frame(height: 200)
                    }
                    
                    // Imported Ride Stats Card
                    if let journey = importedJourney {
                        Section {
                            VStack(spacing: 15) {
                                // Stats Grid
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 15) {
                                    StatCard(title: "Distance", value: journey.distance, emoji: "🏍")
                                    StatCard(title: "Duration", value: journey.duration ?? "00:00", emoji: "⏱")
                                    StatCard(title: "Average Speed", value: journey.averageSpeed ?? "0 mph", emoji: "⚡️")
                                    StatCard(title: "Location", value: journey.location, emoji: "📍")
                                }
                                
                                // Conditions Row
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("Weather")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(journey.weather.emoji)
                                            .font(.title)
                                    }
                                    
                                    VStack {
                                        Text("Mood")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(journey.mood.emoji)
                                            .font(.title)
                                    }
                                    
                                    VStack {
                                        Text("Road")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(journey.road.emoji)
                                            .font(.title)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(15)
                        }
                    }
                    
                    // ... rest of your sections ...
                }
                
                // Import Ride Button
                Button(action: {
                    showingImportSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("Import Ride")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(title.isEmpty)
                }
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
        }
    }
    
    private func importJourney(_ journey: Journey) {
        // Store the journey without adding text
        importedJourney = journey
    }
    
    private func saveEntry() {
        let entry = JournalEntry(
            title: title,
            date: Date(),
            content: content,
            location: importedJourney?.location ?? "",
            hasPhotos: !selectedImages.isEmpty,
            mood: mood,
            images: selectedImages,
            importedJourney: importedJourney
        )
        entries.append(entry)
        dismiss()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImages.append(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    NewJournalEntryView(entries: .constant([
        JournalEntry(
            title: "Great Morning Ride",
            date: Date(),
            content: "Had an amazing ride through the city...",
            location: "Edinburgh",
            hasPhotos: false,
            mood: .happy
        )
        // ... other sample entries
    ]))
} 