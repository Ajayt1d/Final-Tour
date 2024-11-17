import SwiftUI

struct NewJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var location = ""
    @State private var selectedMood: EntryMood = .okay
    
    var onSave: (JournalEntry) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Entry Details")) {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                    
                    Picker("Mood", selection: $selectedMood) {
                        ForEach(EntryMood.allCases, id: \.self) { mood in
                            Text(mood.rawValue)
                        }
                    }
                }
                
                Section(header: Text("Journal Entry")) {
                    TextEditor(text: $content)
                        .frame(height: 200)
                }
                
                Section {
                    Button(action: {
                        // Add photo functionality later
                    }) {
                        Label("Add Photo", systemImage: "photo")
                    }
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveEntry() {
        let entry = JournalEntry(
            title: title,
            date: Date(),
            content: content,
            location: location,
            hasPhotos: false,
            mood: selectedMood
        )
        onSave(entry)
    }
}

#Preview {
    NewJournalEntryView { _ in }
} 