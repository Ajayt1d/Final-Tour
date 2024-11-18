import SwiftUI

struct JournalView: View {
    @State private var entries: [JournalEntry] = [
        JournalEntry(
            title: "Great Morning Ride",
            date: Date(),
            content: "Had an amazing ride through the city...",
            location: "Edinburgh",
            hasPhotos: false,
            mood: .happy
        )
    ]
    @State private var showingNewEntry = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(entries) { entry in
                        NavigationLink(destination: JournalEntryDetailView(entry: binding(for: entry))) {
                            JournalCard(entry: entry)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Journal")
            .toolbar {
                Button(action: {
                    showingNewEntry = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NewJournalEntryView(entries: $entries)
            }
        }
    }
    
    private func binding(for entry: JournalEntry) -> Binding<JournalEntry> {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            fatalError("Entry not found")
        }
        return $entries[index]
    }
}

struct JournalCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(entry.mood.emoji)
                    .font(.system(size: 24))
            }
            
            if !entry.content.isEmpty {
                Text(entry.content)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

private var sampleEntries: [JournalEntry] = [
    JournalEntry(
        title: "Great Morning Ride",
        date: Date(),
        content: "Had an amazing ride through the city...",
        location: "Edinburgh",
        hasPhotos: false,
        mood: .happy
    )
    // ... other sample entries
]

#Preview {
    JournalView()
} 