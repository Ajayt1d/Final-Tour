import SwiftUI

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entry: JournalEntry
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedLocation: String
    @State private var editedMood: EntryMood
    
    init(entry: Binding<JournalEntry>) {
        self._entry = entry
        self._editedTitle = State(initialValue: entry.wrappedValue.title)
        self._editedContent = State(initialValue: entry.wrappedValue.content)
        self._editedLocation = State(initialValue: entry.wrappedValue.location)
        self._editedMood = State(initialValue: entry.wrappedValue.mood)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isEditing {
                    // Edit Mode
                    TextField("Title", text: $editedTitle)
                        .font(.title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Location", text: $editedLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Mood", selection: $editedMood) {
                        ForEach(EntryMood.allCases, id: \.self) { mood in
                            Text(mood.rawValue)
                        }
                    }
                    
                    TextEditor(text: $editedContent)
                        .frame(minHeight: 200)
                        .border(Color.secondary.opacity(0.2))
                } else {
                    // View Mode
                    HStack {
                        Text(entry.title)
                            .font(.title)
                        Text(entry.mood.emoji)
                            .font(.title)
                    }
                    
                    Text(entry.date.formatted(date: .long, time: .shortened))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "location.fill")
                        Text(entry.location)
                    }
                    .foregroundColor(.blue)
                    
                    Text(entry.content)
                        .padding(.top)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        // Save changes
                        entry.title = editedTitle
                        entry.content = editedContent
                        entry.location = editedLocation
                        entry.mood = editedMood
                    }
                    isEditing.toggle()
                }
            }
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