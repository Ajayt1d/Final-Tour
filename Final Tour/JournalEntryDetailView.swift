import SwiftUI

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entry: JournalEntry
    @State private var isEditing = false
    @State private var showingImportSheet = false
    @State private var showingDeleteAlert = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedMood: EntryMood
    @StateObject private var journeyStore = JourneyStore.shared
    
    init(entry: Binding<JournalEntry>) {
        self._entry = entry
        self._editedTitle = State(initialValue: entry.wrappedValue.title)
        self._editedContent = State(initialValue: entry.wrappedValue.content)
        self._editedMood = State(initialValue: entry.wrappedValue.mood)
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
                    }
                } else {
                    HStack {
                        Text(entry.title)
                            .font(.system(size: 24, weight: .bold))
                        Spacer()
                        Text(entry.mood.emoji)
                            .font(.system(size: 30))
                    }
                    
                    Text(entry.date.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(entry.content)
                        .font(.body)
                        .lineSpacing(8)
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
                    }
                    isEditing.toggle()
                }
            }
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Handle delete
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
    }
    
    private func importJourney(_ journey: Journey) {
        let rideSummary = """
        🚲 \(journey.distance) in \(journey.location)
        \(journey.weather.emoji) \(journey.mood.emoji) \(journey.road.emoji)
        """
        
        if editedContent.isEmpty {
            editedContent = rideSummary
        } else {
            editedContent += "\n\n" + rideSummary
        }
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