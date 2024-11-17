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
                    editingView
                } else {
                    viewingView
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var editingView: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Title", text: $editedTitle)
                .font(.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Location", systemImage: "location.fill")
                    .foregroundColor(.secondary)
                TextField("Location", text: $editedLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Mood", systemImage: "face.smiling")
                    .foregroundColor(.secondary)
                Picker("Mood", selection: $editedMood) {
                    ForEach(EntryMood.allCases, id: \.self) { mood in
                        Text(mood.rawValue).tag(mood)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Journal Entry", systemImage: "text.book.closed")
                    .foregroundColor(.secondary)
                TextEditor(text: $editedContent)
                    .frame(minHeight: 200)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
            }
        }
    }
    
    private var viewingView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entry.title)
                        .font(.title)
                        .bold()
                    Spacer()
                    Text(entry.mood.emoji)
                        .font(.title)
                }
                
                Text(entry.date.formatted(date: .long, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
            
            // Location
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text(entry.location)
                    .font(.headline)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text("Journal Entry")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(entry.content)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
            }
            
            if entry.hasPhotos {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Photos")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Photo gallery coming soon...")
                        .foregroundColor(.secondary)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func saveChanges() {
        entry.title = editedTitle
        entry.content = editedContent
        entry.location = editedLocation
        entry.mood = editedMood
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