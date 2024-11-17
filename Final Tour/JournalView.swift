import SwiftUI

struct JournalView: View {
    @State private var showingNewEntry = false
    @State private var entries: [JournalEntry] = sampleEntries
    
    var body: some View {
        VStack {
            // Header
            Text("Journal")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            // Journal Entries List
            ScrollView {
                VStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Entries")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Display entries with binding
                        ForEach($entries) { $entry in
                            JournalEntryCard(
                                entry: $entry,
                                onDelete: {
                                    if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                                        entries.remove(at: index)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.top)
            }
            
            // New Entry Button
            Button(action: {
                showingNewEntry = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New Entry")
                }
                .font(.headline)
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
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView { entry in
                entries.insert(entry, at: 0)
            }
        }
    }
}

struct JournalEntryCard: View {
    @Binding var entry: JournalEntry
    let onDelete: () -> Void
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title, Mood, Date, and Delete Button
            HStack {
                Text(entry.title)
                    .font(.headline)
                
                Text(entry.mood.emoji)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Preview Text
            Text(entry.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Location and Photos indicator
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text(entry.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if entry.hasPhotos {
                    Image(systemName: "photo.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            NavigationView {
                JournalEntryDetailView(entry: $entry)
            }
        }
    }
}

private let sampleEntries: [JournalEntry] = [
    JournalEntry(
        title: "First Day in Scotland",
        date: Date().addingTimeInterval(-86400),
        content: "Started my Highland adventure today. The roads were wet but the scenery was breathtaking. The way the mist rolls over the mountains is something else.",
        location: "Glencoe, Scotland",
        hasPhotos: true,
        mood: .amazing
    ),
    JournalEntry(
        title: "Mountain Pass Challenge",
        date: Date().addingTimeInterval(-172800),
        content: "Tackled some challenging mountain passes today. The bike handled perfectly, though the weather was a bit rough. Need to remember better rain gear next time.",
        location: "Ben Nevis",
        hasPhotos: true,
        mood: .tired
    ),
    JournalEntry(
        title: "Coastal Route",
        date: Date().addingTimeInterval(-259200),
        content: "Perfect weather for a coastal ride. Stopped at a lovely cafe in a fishing village. Met some fellow riders who recommended some great routes.",
        location: "North Coast 500",
        hasPhotos: false,
        mood: .happy
    )
]

#Preview {
    JournalView()
} 