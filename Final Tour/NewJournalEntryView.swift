import SwiftUI

struct NewJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entries: [JournalEntry]
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: EntryMood = .happy
    @State private var showingImportSheet = false
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
                    
                    // Import Ride Button
                    Button(action: {
                        showingImportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import Ride")
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
                            hasPhotos: false,
                            mood: selectedMood
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