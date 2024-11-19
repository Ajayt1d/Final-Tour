import SwiftUI

struct JournalView: View {
    @StateObject private var journalStore = JournalStore.shared
    @State private var showingNewEntry = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Fixed Header
                Text("Journal")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                
                // Scrollable Content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(journalStore.entries.sorted(by: { $0.date > $1.date })) { entry in
                            NavigationLink(destination: JournalEntryDetailView(entry: binding(for: entry))) {
                                JournalCard(entry: entry)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewEntry = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView(entries: $journalStore.entries)
        }
    }
    
    private func binding(for entry: JournalEntry) -> Binding<JournalEntry> {
        guard let index = journalStore.entries.firstIndex(where: { $0.id == entry.id }) else {
            fatalError("Entry not found")
        }
        return $journalStore.entries[index]
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

#Preview {
    JournalView()
} 