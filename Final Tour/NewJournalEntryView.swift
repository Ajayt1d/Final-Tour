import SwiftUI
import UIKit

struct NewJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entries: [JournalEntry]
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: EntryMood = .happy
    @State private var showingImportSheet = false
    @State private var showingImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @StateObject private var journeyStore = JourneyStore.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextEditor(text: $content)
                        .frame(height: 200)
                    
                    // Mood Selection
                    Picker("Mood", selection: $selectedMood) {
                        ForEach(EntryMood.allCases, id: \.self) { mood in
                            Text(mood.emoji)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Import Buttons
                    Button(action: {
                        showingImportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import Ride")
                        }
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Add Photos")
                        }
                    }
                }
                
                if !selectedImages.isEmpty {
                    Section("Photos") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(selectedImages.indices, id: \.self) { index in
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            Button(action: {
                                                selectedImages.remove(at: index)
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
                }
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
                        let entry = JournalEntry(
                            title: title,
                            date: Date(),
                            content: content,
                            location: "",
                            hasPhotos: !selectedImages.isEmpty,
                            mood: selectedMood,
                            images: selectedImages.isEmpty ? nil : selectedImages
                        )
                        entries.insert(entry, at: 0)
                        dismiss()
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
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: $selectedImages)
            }
        }
    }
    
    private func importJourney(_ journey: Journey) {
        let rideSummary = """
        🚲 \(journey.distance) in \(journey.location)
        \(journey.weather.emoji) \(journey.mood.emoji) \(journey.road.emoji)
        """
        
        if content.isEmpty {
            content = rideSummary
        } else {
            content += "\n\n" + rideSummary
        }
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